//
//  WalletPresenter.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt
import PromiseKit
import Web3swift
import EthereumAddress

protocol WalletPresenterDelegate: NSObjectProtocol {
    func walletPresenterBeganRefresh(presenter: WalletPresenter)
    func walletPresenterEndedRefresh(presenter: WalletPresenter)
    func walletPresenter(presenter: WalletPresenter, didRefreshToken tokens: [Token])
    func walletPresenter(presenter: WalletPresenter, didRefreshTotalAmount amount: Double)
    func walletPresenter(presenter: WalletPresenter, didRefreshCurrency currency: LocalCurrency)
    func walletPresenter(presenter: WalletPresenter, didRefreshTokenAmount token: Token)
}

class WalletPresenter {
    var currentWallet: WalletModel?
    var currency: LocalCurrency!
    private (set) var tokens = [Token]()
    weak var delegate: WalletPresenterDelegate?

    private var notificationToken: NotificationToken?
    private(set) var refreshing = false

    init() {
        notificationToken = WalletRealmTool.getCurrentAppModel().observe { [weak self](change) in
            switch change {
            case .change(let propertys):
                guard let wallet = propertys.first(where: { $0.name == "currentWallet" })?.newValue as? WalletModel else { return }
                guard wallet.address != self?.currentWallet?.address else { return }
                self?.refresh()
            default:
                break
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPrice), name: .changeLocalCurrency, object: nil)
    }

    func refresh() {
        guard let appModel = WalletRealmTool.realm.objects(AppModel.self).first(where: { _ in true }) else { return }
        guard let wallet = appModel.currentWallet else { return }
        currentWallet = wallet
        self.tokens = appModel.nativeTokenList.map({ Token($0) })
        self.tokens += wallet.selectTokenList.map({ Token($0) })
        self.tokens.forEach { (token) in
            token.walletAddress = wallet.address
        }
        delegate?.walletPresenter(presenter: self, didRefreshToken: self.tokens)
        refreshBalance()
//        refreshPrice()
    }

    func refreshBalance() {
        refreshing = true
        delegate?.walletPresenterBeganRefresh(presenter: self)
        currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        delegate?.walletPresenter(presenter: self, didRefreshCurrency: currency)
        let tokens = self.tokens
        DispatchQueue.global().async {
            var amount = 0.0
            tokens.forEach { (token) in
                do {
                    let balance = try self.getBalance(token: token)
                    let balanceText = Web3Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 8) ?? "0"
                    token.balance = Double(balanceText)

                    token.price = self.getPrice(token: token)

                    if let price = token.price, let balance = token.balance {
                        amount += price * balance
                    }
                    DispatchQueue.main.async {
                        self.delegate?.walletPresenter(presenter: self, didRefreshTokenAmount: token)
                    }
                } catch {
                }
            }
            DispatchQueue.main.async {
                self.refreshing = false
                self.delegate?.walletPresenterEndedRefresh(presenter: self)
                self.delegate?.walletPresenter(presenter: self, didRefreshTotalAmount: amount)
            }
        }
    }

    @objc func refreshPrice() {
        refreshing = true
        currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        delegate?.walletPresenter(presenter: self, didRefreshCurrency: currency)
        delegate?.walletPresenterBeganRefresh(presenter: self)
        let tokens = self.tokens
        var amount = 0.0
        DispatchQueue.global().async {
            tokens.forEach { (token) in
                token.price = self.getPrice(token: token)
                if let price = token.price, let balance = token.balance {
                    amount += price * balance
                }
                DispatchQueue.main.async {
                    self.delegate?.walletPresenter(presenter: self, didRefreshTokenAmount: token)
                }
            }
            DispatchQueue.main.async {
                self.refreshing = false
                self.delegate?.walletPresenterEndedRefresh(presenter: self)
                self.delegate?.walletPresenter(presenter: self, didRefreshTotalAmount: amount)
            }
        }
    }

    // MARK: - Utils
    func getBalance(token: Token) throws -> BigUInt {
        switch token.type {
        case .ether:
            return try EthereumNetwork().getWeb3().eth.getBalance(address: EthereumAddress(token.walletAddress)!)
        case .appChain:
            return try AppChainNetwork.appChain().rpc.getBalance(address: token.walletAddress)
        default:
            fatalError()
        }
    }

    func getPrice(token: Token) -> Double? {
        let currencyToken = CurrencyService().searchCurrencyId(for: token.symbol)
        guard let tokenId = currencyToken?.id else {
            return nil
        }
        return try? Promise<Double>.init { (resolver) in
            CurrencyService().getCurrencyPrice(tokenid: tokenId, currencyType: currency.short, completion: { (result) in
                switch result {
                case .success(let price):
                    resolver.fulfill(price)
                case .error(let error):
                    resolver.reject(error)
                }
            })
        }.wait()
    }
}
