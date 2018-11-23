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
    func walletPresenter(presenter: WalletPresenter, didSwitchWallet wallet: WalletModel)
    func walletPresenter(presenter: WalletPresenter, didRefreshToken tokens: [Token])
    func walletPresenter(presenter: WalletPresenter, didRefreshTotalAmount amount: Double)
    func walletPresenter(presenter: WalletPresenter, didRefreshCurrency currency: LocalCurrency)
    func walletPresenter(presenter: WalletPresenter, didRefreshTokenAmount token: Token)
}

class WalletPresenter {
    private (set) var currentWallet: WalletModel? {
        didSet {
            guard oldValue?.address != currentWallet?.address else { return }
            delegate?.walletPresenter(presenter: self, didSwitchWallet: currentWallet!)
        }
    }
    private (set) var currency: LocalCurrency! {
        didSet {
            guard oldValue?.name != currency?.name else { return }
            delegate?.walletPresenter(presenter: self, didRefreshCurrency: currency)
        }
    }
    private (set) var tokens = [Token]() {
        didSet {
            self.tokenListTimestamp = Date().timeIntervalSince1970
            delegate?.walletPresenter(presenter: self, didRefreshToken: tokens)
        }
    }
    private(set) var refreshing = false
    weak var delegate: WalletPresenterDelegate?

    private var appModelObserver: NotificationToken?
    private var selectTokenListObserver: NotificationToken?
    private var nativeTokenListObserver: NotificationToken?

    private var tokenListTimestamp: TimeInterval = 0.0

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBalance), name: .switchEthNetwork, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPrice), name: .changeLocalCurrency, object: nil)
        observeAppModel()
        observeNativeTokenList()
    }

    func refresh() {
        let appModel = AppModel.current
        guard let wallet = appModel.currentWallet else { return }
        currentWallet = wallet

        var tokens = [Token]()
        tokens += AppModel.current.nativeTokenList.map({ Token($0) })
        tokens += wallet.selectTokenList.map({ Token($0) })
        tokens.forEach { (token) in
            token.walletAddress = self.currentWallet!.address
        }
        self.tokens = tokens
        self.tokenListTimestamp = Date().timeIntervalSince1970
        refreshBalance()

        observeWalletSelectTokenList()
    }

    @objc func refreshBalance() {
        currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        delegate?.walletPresenter(presenter: self, didRefreshCurrency: currency)
        refreshTokenListBalance(tokens: self.tokens)
    }
}

// MARK: - Observer
extension WalletPresenter {
    private func observeAppModel() {
        appModelObserver = AppModel.current.observe { [weak self] (change) in
            switch change {
            case .change(let propertys):
                guard let wallet = propertys.first(where: { $0.name == "currentWallet" })?.newValue as? WalletModel else { return }
                // TODO: When current wallet gets deleted accessing it would throw a realm invalid object exception
                guard wallet.address != self?.currentWallet?.address else { return }
                self?.refresh()
            default:
                break
            }
        }
    }

    private func observeWalletSelectTokenList() {
        guard let wallet = currentWallet else { return }
        selectTokenListObserver?.invalidate()
        selectTokenListObserver = wallet.selectTokenList.observe({ [weak self] (change) in
            guard let self = self else { return }
            self.tokenListChangeHandler(change: change)
        })
    }

    private func observeNativeTokenList() {
        nativeTokenListObserver?.invalidate()
        nativeTokenListObserver = AppModel.current.nativeTokenList.observe { [weak self] (change) in
            guard let self = self else { return }
            self.tokenListChangeHandler(change: change)
        }
    }
}

extension WalletPresenter {
    private func tokenListChangeHandler(change: RealmCollectionChange<List<TokenModel>>) {
        switch change {
        case .update(let tokenList, let deletions, let insertions, modifications: _):
            guard deletions.count > 0 || insertions.count > 0 else { return }
            if deletions.count > 0 {
                var newTokens = tokens
                deletions.enumerated().forEach({ (offset, element) in
                    let index = element - offset
                    newTokens.remove(at: index)
                })
                tokens = newTokens
            }
            if insertions.count > 0 {
                let newTokens = insertions.map({ (idx) -> Token in
                    let token = Token(tokenList[idx])
                    token.walletAddress = currentWallet!.address
                    return token
                })
                tokens += newTokens
                refreshTokenListBalance(tokens: newTokens)
            }
        default:
            break
        }
    }

    private func refreshTokenListBalance(tokens: [Token]) {
        guard tokens.count > 0 else { return }
        refreshing = true
        delegate?.walletPresenterBeganRefresh(presenter: self)
        let timestamp = self.tokenListTimestamp
        DispatchQueue.global().async {
            tokens.forEach { (token) in
                guard self.tokens.contains(where: { $0 == token }) else { return }
                do {
                    try token.refreshBalance()
                    token.price = self.getTokenPrice(token: token)
                    DispatchQueue.main.async {
                        self.delegate?.walletPresenter(presenter: self, didRefreshTokenAmount: token)
                    }
                } catch {
                }
            }
            var amount = 0.0
            self.tokens.forEach({ (token) in
                if let price = token.price, let balance = token.balance {
                    amount += price * balance
                }
            })
            DispatchQueue.main.async {
                guard timestamp == self.tokenListTimestamp else { return }
                self.refreshing = false
                self.delegate?.walletPresenterEndedRefresh(presenter: self)
                self.delegate?.walletPresenter(presenter: self, didRefreshTotalAmount: amount)
            }
        }
    }

    @objc func refreshPrice() {
        self.currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        delegate?.walletPresenterBeganRefresh(presenter: self)
        let tokens = self.tokens
        let currency = self.currency
        let timestamp = self.tokenListTimestamp
        DispatchQueue.global().async {
            var amount = 0.0
            tokens.forEach { (token) in
                token.price = self.getTokenPrice(token: token)
                if let price = token.price, let balance = token.balance {
                    amount += price * balance
                }
                DispatchQueue.main.async {
                    self.delegate?.walletPresenter(presenter: self, didRefreshTokenAmount: token)
                }
            }
            DispatchQueue.main.async {
                guard currency?.short == self.currency.short else { return }
                guard timestamp == self.tokenListTimestamp else { return }
                self.refreshing = false
                self.delegate?.walletPresenterEndedRefresh(presenter: self)
                self.delegate?.walletPresenter(presenter: self, didRefreshTotalAmount: amount)
            }
        }
    }
}

// MARK: - Utils
extension WalletPresenter {
    private func getTokenPrice(token: Token) -> Double? {
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
