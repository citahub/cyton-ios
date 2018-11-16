//
//  TransactionHistoryPresenter.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol TransactionHistoryPresenterDelegate: NSObjectProtocol {
    func didLoadTransactions(transaction: [TransactionDetails], insertions: [Int], error: Error?)
    func updateTransactions(transaction: [TransactionDetails], updates: [Int], error: Error?)
}

class TransactionHistoryPresenter: NSObject, TransactionStatusManagerDelegate {
    private(set) var transactions = [TransactionDetails]()
    private var sentTransactions = [TransactionDetails]()
    let token: TokenModel
    typealias CallbackBlock = ([Int], Error?) -> Void
    var tokenProfile: TokenProfile?

    init(token: TokenModel) {
        self.token = token
        walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        tokenAddress = token.address
        tokenType = token.type
        super.init()
        TransactionStatusManager.manager.addDelegate(delegate: self)
    }

    private var hasMoreData = true
    weak var delegate: TransactionHistoryPresenterDelegate?

    func reloadData(completion: CallbackBlock? = nil) {
        guard loading == false else { return }
        page = 1
        hasMoreData = true
        loadMoreData(completion: completion)
    }

    func loadMoreData(completion: CallbackBlock? = nil) {
        guard loading == false else { return }
        guard hasMoreData else { return }
        loading = true
        DispatchQueue.global().async {
            do {
                var list = try self.loadData()
                self.hasMoreData = list.count == self.pageSize
                self.loading = false
                if self.page == 1 {
                    self.transactions = []
                    self.sentTransactions = TransactionStatusManager.manager.getTransactions(walletAddress: self.walletAddress, tokenType: self.tokenType, tokenAddress: self.tokenAddress)
                }
                self.page += 1

                // merge
                list = self.mergeSentTransactions(from: list)

                var insertions = [Int]()
                for idx in list.indices {
                    insertions.append(self.transactions.count + idx)
                }

                self.transactions.append(contentsOf: list)
                DispatchQueue.main.async {
                    completion?(insertions, nil)
                    self.delegate?.didLoadTransactions(transaction: self.transactions, insertions: insertions, error: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion?([], error)
                    self.delegate?.didLoadTransactions(transaction: self.transactions, insertions: [], error: error)
                }
            }
        }
    }

    // MARK: - Merge
    private func mergeSentTransactions(from list: [TransactionDetails]) -> [TransactionDetails] {
        let sDate: Date = self.transactions.first?.date ?? Date.distantFuture
        let eDate: Date
        if self.hasMoreData {
            eDate = list.last?.date ?? Date.distantPast
        } else {
            eDate = Date.distantPast
        }
        let sentTransactions = self.sentTransactions
        let sentList = sentTransactions.filter({ (sentTransaction) -> Bool in
            // merge status
            if let transaction = list.first(where: { (item) -> Bool in
                return item.hash == sentTransaction.hash
            }) {
                // remove sentTransaction
                self.sentTransactions.removeAll(where: { (entity) -> Bool in
                    return entity.hash == sentTransaction.hash
                })
                transaction.status = sentTransaction.status
                return false
            }
            if sentTransaction.date < sDate && sentTransaction.date > eDate {
                // remove sentTransaction
                self.sentTransactions.removeAll(where: { (entity) -> Bool in
                    return entity.hash == sentTransaction.hash
                })
                return true
            } else {
                return false
            }
        })
        return (list + sentList).sorted(by: { (details1, details2) -> Bool in
            return details1.date > details2.date
        })
    }

    // MARK: - Load transactions
    private var loading = false
    private var page: UInt = 1
    private var pageSize: UInt = 10
    private let walletAddress: String
    private let tokenAddress: String
    private let tokenType: TokenModel.TokenType

    private func loadData() throws -> [TransactionDetails] {
        switch tokenType {
        case .nervos:
            return try AppChainNetwork().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .ethereum:
            return try EthereumNetwork().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .erc20:
            return try EthereumNetwork().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        case .nervosErc20:
            return try AppChainNetwork().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        }
    }

    // MARK: - TransactionStatusManagerDelegate
    func sentTransactionInserted(transaction: TransactionDetails) {
        guard transaction.from == walletAddress else {
            return
        }
        DispatchQueue.main.async {
            self.transactions.insert(transaction, at: 0)
            self.delegate?.didLoadTransactions(transaction: self.transactions, insertions: [0], error: nil)
        }
    }
    func sentTransactionStatusChanged(transaction: TransactionDetails) {
        DispatchQueue.main.async {
            for (idx, trans) in self.transactions.enumerated() {
                if trans.hash == transaction.hash {
//                    trans.status = transaction.status
                    self.transactions.remove(at: idx)
                    self.transactions.insert(transaction, at: idx)
                    self.delegate?.updateTransactions(transaction: self.transactions, updates: [idx], error: nil)
                    return
                }
            }
        }
    }
}
