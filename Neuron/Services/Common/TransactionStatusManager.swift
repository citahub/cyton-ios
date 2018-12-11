//
//  TransactionStatusManager.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

enum TransactionStateResult {
    case pending
    case success(transaction: TransactionDetails)
    case failure
}

protocol TransactionStatusManagerDelegate: NSObjectProtocol {
    func sentTransactionInserted(transaction: TransactionDetails)
    func sentTransactionStatusChanged(transaction: TransactionDetails)
}

class TransactionStatusManager: NSObject {
    static let manager = TransactionStatusManager()
    private var transactions = [LocationTxDetailsModel]()
    private var taskThread = TaskThread()
    private var realm: Realm!

    private override init() {
        delegates = NSHashTable(options: .weakMemory)
        super.init()
        configureTxStatusManager()
    }

    private func configureTxStatusManager() {
        guard taskThread.thread == nil else { return }
        realm = try! Realm()
        taskThread.run()
        taskThread.perform {
            self.transactions = self.realm.objects(LocationTxDetailsModel.self).filter({ (transaction) -> Bool in
                return transaction.status == .pending
            })
            self.checkSentTransactionStatus()
        }
    }

    // MARK: - delegate
    private let delegates: NSHashTable<NSObject>!

    func addDelegate(delegate: TransactionStatusManagerDelegate) {
        delegates.add(delegate as? NSObject)
    }

    func removeDelegate(delegate: TransactionStatusManagerDelegate) {
        delegates.remove(delegate as? NSObject)
    }

    // MARK: - Add transaction
    func insertTransaction(transaction: LocationTxDetailsModel) {
        configureTxStatusManager()
        taskThread.perform {
            try? self.realm.write {
                self.realm.add(transaction)
            }
            self.transactions.append(transaction)
            let details = transaction.transactionDetails()
            for delegate in self.delegates.allObjects {
                if let delegate = delegate as? TransactionStatusManagerDelegate {
                    delegate.sentTransactionInserted(transaction: details)
                }
            }
            if self.transactions.count == 1 {
                self.checkSentTransactionStatus()
            }
        }
    }

    // MARK: - 
    func getTransactions(walletAddress: String, tokenType: TokenType, tokenAddress: String, chainHosts: String) -> [TransactionDetails] {
        let ethereumNetwork = EthereumNetwork().host().absoluteString
        return self.realm.objects(LocationTxDetailsModel.self).filter({
            $0.chainHosts == chainHosts &&
            $0.from == walletAddress &&
            $0.tokenType == tokenType &&
            $0.contractAddress == tokenAddress &&
            ($0.ethereumNetwork == "" || $0.ethereumNetwork == ethereumNetwork)
        }).map({ $0.transactionDetails() })
    }

    // MARK: - Check transaction status
    private let timeInterval: TimeInterval = 4.0

    @objc private func checkSentTransactionStatus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkSentTransactionStatus), object: nil)
        guard self.transactions.count > 0 else {
            taskThread.stop()
            return
        }
        guard Thread.current == taskThread.thread else {
            taskThread.perform { self.checkSentTransactionStatus() }
            return
        }

        let transactions = self.transactions
        for sentTransaction in transactions {
            let result: TransactionStateResult
            switch sentTransaction.tokenType {
            case .ether:
                result = EthereumNetwork().getTransactionStatus(sentTransaction: sentTransaction)
            case .erc20:
                result = EthereumNetwork().getTransactionStatus(sentTransaction: sentTransaction)
            case .appChain:
                result = AppChainNetwork().getTransactionStatus(sentTransaction: sentTransaction)
            default:
                fatalError()
            }

            switch result {
            case .failure:
                self.transactions.removeAll { $0 == sentTransaction }
                try? self.realm.write {
                    sentTransaction.status = .failure
                }
                sentTransactionStatusChanged(transaction: sentTransaction.transactionDetails())
            case .success(let details):
                self.transactions.removeAll { $0 == sentTransaction }
                try? self.realm.write {
                    sentTransaction.status = .success
                    realm.delete(sentTransaction)
                }
                sentTransactionStatusChanged(transaction: details)
            case .pending:
                break
            }
        }
        perform(#selector(checkSentTransactionStatus), with: nil, afterDelay: timeInterval)
    }

    // MARK: - Callback
    private func sentTransactionStatusChanged(transaction: TransactionDetails) {
        for delegate in self.delegates.allObjects {
            if let delegate = delegate as? TransactionStatusManagerDelegate {
                delegate.sentTransactionStatusChanged(transaction: transaction)
            }
        }
    }
}
