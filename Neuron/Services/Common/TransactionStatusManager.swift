//
//  TransactionStatusManager.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt
import Web3swift
import AppChain

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
    private var transactions = [SentTransaction]()

    private override init() {
        delegates = NSHashTable(options: .weakMemory)
        super.init()
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
        let ethereumNetwork = EthereumNetwork().host().absoluteString
        return self.realm.objects(SentTransaction.self).filter({
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
            deleteTaskThread()
            return
        }
        guard Thread.current == thread else {
            perform { self.checkSentTransactionStatus() }
            return
        }

        let transactions = self.transactions
        for sentTransaction in transactions {
            let result: TransactionStateResult
            switch sentTransaction.tokenType {
            case .ethereum:
                result = EthereumNetwork().getTransactionStatus(sentTransaction: sentTransaction)
            case .erc20:
                result = EthereumNetwork().getTransactionStatus(sentTransaction: sentTransaction)
            case .nervos:
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

    // MARK: - Thread
    private var thread: Thread?
    private var runLoop: RunLoop?
    private typealias Block = () -> Void
    private class Task: NSObject {
        let block: Block
        init(block: @escaping Block) {
            self.block = block
        }
    }

    @objc private func perform(_ block: @escaping Block) {
        let thread = getTaskThread()
        if Thread.current == thread {
            block()
            return
        }
        let task = Task(block: block)
        let sel = #selector(TransactionStatusManager.taskHandler(task:))
        self.perform(sel, on: thread, with: task, waitUntilDone: false)
    }

    @objc private func syncPerform(_ block: @escaping Block) {
        let thread = getTaskThread()
        if Thread.current == thread {
            block()
            return
        }
        let task = Task(block: block)
        let sel = #selector(TransactionStatusManager.taskHandler(task:))
        self.perform(sel, on: thread, with: task, waitUntilDone: true)
    }

    @objc private func taskHandler(task: Task) {
        task.block()
    }

    private func getTaskThread() -> Thread {
        if let thread = thread {
            return thread
        }
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "")
        group.enter()
        queue.async {
            self.thread = Thread.current
            self.runLoop = RunLoop.current
            Thread.current.name = String(describing: TransactionStatusManager.self)
            RunLoop.current.add(NSMachPort(), forMode: .default)
            group.leave()
            CFRunLoopRun()
        }
        group.wait()
        perform {
            self.transactions = self.realm.objects(SentTransaction.self).filter({ (transaction) -> Bool in
                return transaction.status == .pending
            })
        }
        return thread!
    }

    private func deleteTaskThread() {
        self.thread = nil
        if let runloop = self.runLoop?.getCFRunLoop() {
            CFRunLoopStop(runloop)
        }
    }

    private var realm: Realm! {
        return RealmHelper().realm
    }
}
