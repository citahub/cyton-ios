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
    let token: TokenModel
    typealias CallbackBlock = ([Int], Error?) -> Void
    weak var delegate: TransactionHistoryPresenterDelegate?
    private var hasMoreData = true
    private var sentTransactions = [TransactionDetails]()

    init(token: TokenModel) {
        self.token = token
        walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        tokenAddress = token.address
        tokenType = token.type
        super.init()
        TransactionStatusManager.manager.addDelegate(delegate: self)
    }

    func reloadData(completion: CallbackBlock? = nil) {
        guard !loading else {
            return 
        }
        page = 1
        hasMoreData = true
        loadMoreData(completion: completion)
    }

    func loadMoreData(completion: CallbackBlock? = nil) {
        guard loading == false else { return }
        guard hasMoreData else {
           return
        }
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
        // Date range
        let maxDate: Date = self.transactions.first?.date ?? Date.distantFuture
        let minDate: Date
        if self.hasMoreData {
            minDate = list.last?.date ?? Date.distantPast
        } else {
            minDate = Date.distantPast
        }
        let sentTransactions = self.sentTransactions
        let sentList = sentTransactions.filter({ (sentTransaction) -> Bool in
            // merge status
            if let transaction = list.first(where: { $0.hash == sentTransaction.hash }) {
                self.sentTransactions.removeAll(where: { $0.hash == sentTransaction.hash })
                transaction.status = sentTransaction.status
                return false
            }
            if sentTransaction.date < maxDate && sentTransaction.date > minDate {
                self.sentTransactions.removeAll(where: { $0.hash == sentTransaction.hash })
                return true
            } else {
                return false
            }
        })
        return (list + sentList).sorted(by: { $0.date > $1.date })
    }

    // MARK: - Load transactions
    private var loading = false
    private var page: UInt = 1
    private var pageSize: UInt = 10
    private let walletAddress: String
    private let tokenAddress: String
    private let tokenType: TokenType

    private func loadData() throws -> [TransactionDetails] {
        switch tokenType {
        case .appChain:
            return try AppChainNetwork().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .ether:
            return try EthereumNetwork().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .erc20:
            return try EthereumNetwork().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        case .appChainErc20:
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
                    self.transactions.remove(at: idx)
                    self.transactions.insert(transaction, at: idx)
                    self.delegate?.updateTransactions(transaction: self.transactions, updates: [idx], error: nil)
                    return
                }
            }
        }
    }
}
