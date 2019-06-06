//
//  WalletPresenter.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt
import web3swift

protocol WalletPresenterDelegate: NSObjectProtocol {
    func walletPresenterBeganRefresh(presenter: WalletPresenter)
    func walletPresenterEndedRefresh(presenter: WalletPresenter)
    func walletPresenter(presenter: WalletPresenter, didSwitchWallet wallet: WalletModel)
    func walletPresenter(presenter: WalletPresenter, didRefreshToken tokens: [Token])
    func walletPresenter(presenter: WalletPresenter, didRefreshTotalAmount amount: NSDecimalNumber)
    func walletPresenter(presenter: WalletPresenter, didRefreshCurrency currency: LocalCurrency)
    func walletPresenter(presenter: WalletPresenter, didRefreshTokenAmount token: Token)
}

class WalletPresenter {
    private (set) var currentWallet: WalletModel? {
        didSet {
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
    }

    func refresh() {
        let appModel = AppModel.current
        guard let wallet = appModel.currentWallet else { return }
        currentWallet = wallet

        var tokens = [Token]()
        tokens = wallet.selectedTokenList.map { Token($0, currentWallet!.address) }
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
                guard propertys.contains(where: { $0.name == "currentWallet" }) else { return }
                DispatchQueue.main.async {
                    self?.refresh()
                }
            default:
                break
            }
        }
    }

    private func observeWalletSelectTokenList() {
        guard let wallet = currentWallet else { return }
        selectTokenListObserver?.invalidate()
        selectTokenListObserver = wallet.selectedTokenList.observe({ [weak self] (change) in
            guard let self = self else { return }
            switch change {
            case .update(let tokenList, let deletions, let insertions, modifications: _):
                guard deletions.count > 0 || insertions.count > 0 else { return }
                if deletions.count > 0 {
                    var newTokens = self.tokens
                    deletions.enumerated().forEach({ (offset, element) in
                        let index = element - offset
                        newTokens.remove(at: index)
                    })
                    self.tokens = newTokens
                }
                self.insertTokens(tokenList: tokenList, insertions: insertions)
            default:
                break
            }
        })
    }

    private func insertTokens(tokenList: List<TokenModel>, insertions: [Int]) {
        guard insertions.count > 0 else { return }
        let newTokens = insertions.map({ Token(tokenList[$0], self.currentWallet!.address) })
        for (idx, token) in newTokens.enumerated() {
            self.tokens.insert(token, at: insertions[idx])
        }
        self.refreshTokenListBalance(tokens: newTokens)
    }
}

extension WalletPresenter {
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
            var amount = NSDecimalNumber(value: 0.0)
            self.tokens.forEach({ (token) in
                if let price = token.price, let balance = token.balance {
                    let tokenAmount = balance.toDecimalNumber(token.decimals).multiplying(by: NSDecimalNumber(value: price))
                    amount = amount.adding(tokenAmount)
                }
            })
            DispatchQueue.main.async {
                self.refreshing = false
                guard timestamp == self.tokenListTimestamp else { return }
                self.delegate?.walletPresenterEndedRefresh(presenter: self)
                self.delegate?.walletPresenter(presenter: self, didRefreshTotalAmount: amount)
            }
        }
    }

    @objc func refreshPrice() {
        self.currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        refreshing = true
        delegate?.walletPresenterBeganRefresh(presenter: self)
        let tokens = self.tokens
        let currency = self.currency
        let timestamp = self.tokenListTimestamp
        DispatchQueue.global().async {
            var amount = NSDecimalNumber(value: 0.0)
            tokens.forEach { (token) in
                token.price = self.getTokenPrice(token: token)
                if let price = token.price, let balance = token.balance {
                    let tokenAmount = balance.toDecimalNumber(token.decimals).multiplying(by: NSDecimalNumber(value: price))
                    amount = amount.adding(tokenAmount)
                }
                DispatchQueue.main.async {
                    self.delegate?.walletPresenter(presenter: self, didRefreshTokenAmount: token)
                }
            }
            DispatchQueue.main.async {
                self.refreshing = false
                guard currency?.short == self.currency.short else { return }
                guard timestamp == self.tokenListTimestamp else { return }
                self.delegate?.walletPresenterEndedRefresh(presenter: self)
                self.delegate?.walletPresenter(presenter: self, didRefreshTotalAmount: amount)
            }
        }
    }
}

// MARK: - Utils
extension WalletPresenter {
    private func getTokenPrice(token: Token) -> Double? {
        switch token.type {
        case .cita, .citaErc20:
            return nil
        case .erc20, .ether:
            return TokenPriceLoader().getPrice(symbol: token.symbol, currency: currency.short)
        }
    }
}
