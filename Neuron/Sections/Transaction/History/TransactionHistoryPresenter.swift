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

class TransactionHistoryPresenter: NSObject {
    private(set) var transactions = [TransactionDetails]()
    let token: Token
    typealias CallbackBlock = ([Int], Error?) -> Void
    weak var delegate: TransactionHistoryPresenterDelegate?
    private var hasMoreData = true
    private var sentTransactions = [TransactionDetails]()

    init(token: Token) {
        self.token = token
        super.init()
        observeTxStatus()
    }

    func reloadData(completion: CallbackBlock? = nil) {
        guard !loading else { return }
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
                    self.sentTransactions = TxStatusManager.manager.getTransactions(token: self.token)
                }
                self.page += 1

                // merge
                list = self.mergeSentTransactions(from: list)
                list.forEach({$0.token = self.token})

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
        var newList = [TransactionDetails]()
        list.forEach { (trans) in
            if !newList.contains(where: { $0.hash == trans.hash }) {
                newList.append(trans)
            }
        }

        // Date range
        let maxDate: Date = self.transactions.first?.date ?? Date.distantFuture
        let minDate: Date
        if self.hasMoreData {
            minDate = newList.last?.date ?? Date.distantPast
        } else {
            minDate = Date.distantPast
        }
        let sentTransactions = self.sentTransactions
        let sentList = sentTransactions.filter({ (sentTransaction) -> Bool in
            // merge status
            if sentTransaction.status == .pending {
                newList.removeAll(where: { $0.hash == sentTransaction.hash })
                return true
            }
            if let transaction = newList.first(where: { $0.hash == sentTransaction.hash }) {
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
        return (newList + sentList).sorted(by: { $0.date > $1.date })
    }

    // MARK: - Load transactions
    private var loading = false
    private var page: UInt = 1
    private var pageSize: UInt = 20

    private func loadData() throws -> [TransactionDetails] {
        switch token.type {
        case .appChain:
            if token.symbol == "NATT" {
                return try AppChainNetwork().getTransactionHistory(walletAddress: token.walletAddress, page: page, pageSize: pageSize)
            } else {
                return []
            }
        case .ether:
            return try EthereumNetwork().getTransactionHistory(walletAddress: token.walletAddress, page: page, pageSize: pageSize)
        case .erc20:
            return try EthereumNetwork().getErc20TransactionHistory(walletAddress: token.walletAddress, tokenAddress: token.address, page: page, pageSize: pageSize)
        case .appChainErc20:
            return try AppChainNetwork().getErc20TransactionHistory(walletAddress: token.walletAddress, tokenAddress: token.address, page: page, pageSize: pageSize)
        }
    }
}

extension TransactionHistoryPresenter {
    private func observeTxStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(didAddLocationTxDetails(notification:)), name: TxStatusManager.didAddLocationTxDetails, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateTxStatus(notification:)), name: TxStatusManager.didUpdateTxStatus, object: nil)
    }

    @objc func didAddLocationTxDetails(notification: Notification) {
        guard let transaction = notification.userInfo![TxStatusManager.transactionKey] as? TransactionDetails else { return }
        guard transaction.token == token else { return }
        transactions.insert(transaction, at: 0)
        delegate?.didLoadTransactions(transaction: transactions, insertions: [0], error: nil)
    }

    @objc func didUpdateTxStatus(notification: Notification) {
        guard let transaction = notification.userInfo![TxStatusManager.transactionKey] as? TransactionDetails else { return }
        guard transaction.token == token else { return }
        guard let idx = transactions.firstIndex(where: { $0.hash == transaction.hash }) else { return }
        transactions.remove(at: idx)
        transactions.insert(transaction, at: idx)
        delegate?.updateTransactions(transaction: transactions, updates: [idx], error: nil)
    }
}
