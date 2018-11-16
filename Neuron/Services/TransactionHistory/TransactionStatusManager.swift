//
//  TransactionStateService.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt
import Web3swift
import AppChain

enum TransactionStateResult {
    case pending
    case success(transaction: TransactionDetails)
    case failure
}

extension Array where Element: Equatable {
    @discardableResult func index(object: Element) -> Int? {
        for (idx, obj) in enumerated() {
            if obj == object {
                return idx
            }
        }
        return nil
    }
}

protocol TransactionStatusManagerDelegate: NSObjectProtocol {
    func sentTransactionInserted(transaction: TransactionDetails)
    func sentTransactionStatusChanged(transaction: TransactionDetails)
}

class TransactionStatusManager: NSObject {
    private typealias Block = () -> Void
    private class Task: NSObject {
        let block: Block
        init(block: @escaping Block) {
            self.block = block
        }
    }

    static let transactionStatusChangedNotification = Notification.Name("transactionStatusChangedNotification")
    static let manager = TransactionStatusManager()
    private var realm: Realm!
    private var transactions = [SentTransaction]()

    private override init() {
        let document = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
        let fileURL = document.appendingPathComponent("transaction_history")
//        try? FileManager.default.removeItem(at: fileURL)
        delegates = NSHashTable(options: .weakMemory)
        super.init()

        createTaskThread()
        perform {
            self.realm = try! Realm(fileURL: fileURL)
            let objects = self.realm.objects(SentTransaction.self)
            self.transactions = objects.filter({ (transaction) -> Bool in
                return transaction.status == .pending
            })
            print("[TransactionStatus] - 加载需要检查状态的交易: \(self.transactions.count)")
        }
        perform {
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
    func insertTransaction(transaction: SentTransaction) {
        perform {
            try? self.realm.write {
                self.realm.add(transaction)
            }
            self.transactions.append(transaction)
            print("[TransactionStatus] - 新增交易 \(transaction.txHash)")
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
    func getTransactions(walletAddress: String, tokenType: TokenModel.TokenType, tokenAddress: String) -> [TransactionDetails] {
        var transactions: [TransactionDetails]?
        syncPerform {
            transactions = self.realm.objects(SentTransaction.self).filter({ (transaction) -> Bool in
                return transaction.from == walletAddress &&
                    transaction.tokenType == tokenType &&
                    transaction.contractAddress == tokenAddress
            }).map({ (sent) -> TransactionDetails in
                return sent.transactionDetails()
            })
        }
        return transactions ?? []
    }

    // MARK: - Check transaction status
    private let timeInterval: TimeInterval = 4.0

    @objc private func checkSentTransactionStatus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkSentTransactionStatus), object: nil)
        guard self.transactions.count > 0 else {
            print("[TransactionStatus] - 全部交易状态检查完成")
            return
        }
        guard Thread.current == thread else {
            perform {
                self.checkSentTransactionStatus()
            }
            return
        }

        let transactions = self.transactions
        for transaction in transactions {
            let result: TransactionStateResult
            print("[TransactionStatus] - 开始检查交易状态: \(transaction.txHash)")
            switch transaction.tokenType {
            case .ethereum:
                result = EthereumTransactionStatus().getTransactionStatus(sentTransaction: transaction)
            case .erc20:
                result = EthereumTransactionStatus().getTransactionStatus(sentTransaction: transaction)
            case .nervos:
                result = AppChainTransactionStatus().getTransactionStatus(sentTransaction: transaction)
            default:
                fatalError()
            }

            switch result {
            case .failure:
                print("[TransactionStatus] - 交易失败: \(transaction.txHash)")
                self.transactions.removeAll { (item) -> Bool in
                    return item == transaction
                }
                try? self.realm.write {
                    transaction.status = .failure
                }
                let details = transaction.transactionDetails()
                for delegate in self.delegates.allObjects {
                    if let delegate = delegate as? TransactionStatusManagerDelegate {
                        delegate.sentTransactionStatusChanged(transaction: details)
                    }
                }
            case .success(let details):
                print("[TransactionStatus] - 交易成功: \(transaction.txHash)")
                try? self.realm.write {
                    transaction.status = .success
                    realm.delete(transaction)
                }
                self.transactions.removeAll { (item) -> Bool in
                    return item == transaction
                }
                for delegate in self.delegates.allObjects {
                    if let delegate = delegate as? TransactionStatusManagerDelegate {
                        delegate.sentTransactionStatusChanged(transaction: details)
                    }
                }
            case .pending:
                print("[TransactionStatus] - 交易进行中: \(transaction.txHash)")
            }
        }
        perform(#selector(checkSentTransactionStatus), with: nil, afterDelay: timeInterval)
    }

    // MARK: - Thread
    private var thread: Thread!

    @objc private func perform(_ block: @escaping Block) {
        if Thread.current == thread {
            block()
            return
        }
        let task = Task(block: block)
        let sel = #selector(TransactionStatusManager.taskHandler(task:))
        self.perform(sel, on: self.thread, with: task, waitUntilDone: false)
    }

    @objc private func syncPerform(_ block: @escaping Block) {
        if Thread.current == thread {
            block()
            return
        }
        let task = Task(block: block)
        let sel = #selector(TransactionStatusManager.taskHandler(task:))
        self.perform(sel, on: self.thread, with: task, waitUntilDone: true)
    }

    @objc private func taskHandler(task: Task) {
        task.block()
    }
//
//    func value<T>(_ block: (TransactionStatusManager) -> T) -> T {
//        let value = block(self)
//        return value
//    }

    private func createTaskThread() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "")
        group.enter()
        queue.async {
            self.thread = Thread.current
            Thread.current.name = String(describing: TransactionStatusManager.self)
            RunLoop.current.add(NSMachPort(), forMode: .default)
            group.leave()
            RunLoop.current.run()
        }
        group.wait()
    }
}
