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
    private let timeInterval: TimeInterval = 4.0
    private var realm: Realm!
    private var transactions = [SentTransaction]()
    private let delegates: NSHashTable<NSObject>!
    private var objects: Results<SentTransaction>!

    private override init() {
        let document = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
        let fileURL = document.appendingPathComponent("transaction_history")
//        try? FileManager.default.removeItem(at: fileURL)
        delegates = NSHashTable(options: .weakMemory)
        super.init()

        createTaskThread()
        perform {
            self.realm = try! Realm(fileURL: fileURL)
            self.objects = self.realm.objects(SentTransaction.self)
//            self.transactions = self.objects.map { (transaction) -> SentTransaction in
//                transaction.setupThreadSafe()
//                return transaction
//            }
            self.transactions = self.objects.filter({ (transaction) -> Bool in
                return transaction.status == .pending || transaction.status == .failure
            })
            print("[TransactionStatus] - 加载需要检查状态的交易: \(self.transactions.count)")
        }

        ///
        perform {
            self.checkSentTransactionStatus()
        }
    }

    func addDelegate(delegate: TransactionStatusManagerDelegate) {
        delegates.add(delegate as? NSObject)
    }

    func removeDelegate(delegate: TransactionStatusManagerDelegate) {
        delegates.remove(delegate as? NSObject)
    }

    func test() {
//        let transaction = SentTransactionEntity()
//        transaction.hashString = "0x52c7dd85173d8d1ec96c6cf46bede4241bd937836181068ede04a2baa69013d3"
//        transaction.blockNumber = BigUInt("4ce27", radix: 16)!
//        let result = AppChainTransactionStatus().getTransactionStatus(transaction: transaction)
//        print(result)
        let walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        DispatchQueue.global().async {
//            let transactions = try? AppChainTransactionHistory().getTransactionHistory(walletAddress: walletAddress, page: 1, pageSize: 4)
            let transactions = try? EthereumTransactionHistory().getTransactionHistory(walletAddress: walletAddress, page: 1, pageSize: 4)
            print(transactions ?? [])
            print(transactions ?? [])
        }
    }

    func insertTransaction(transaction: SentTransaction) {
        guard Thread.current == thread else {
            perform {
                self.insertTransaction(transaction: transaction)
            }
            return
        }
        try? realm.write {
            realm.add(transaction)
        }
        transactions.append(transaction)
        print("[TransactionStatus] - 新增交易 \(transaction.txHash)")
        let details = transaction.transactionDetails()
        for delegate in self.delegates.allObjects {
            if let delegate = delegate as? TransactionStatusManagerDelegate {
                delegate.sentTransactionInserted(transaction: details)
            }
        }
        if transactions.count == 1 {
            checkSentTransactionStatus()
        }
    }

//    func mergeTransactions(from transactions: [TransactionDetails]) -> [TransactionDetails] {
//        return transactions
//    }

    func getTransactions(walletAddress: String, token: TokenModel) -> [SentTransaction] {
        return transactions.filter({ (entity) -> Bool in
            return entity.from == walletAddress && entity.isSendFromToken(token: token)
        })
    }

    // MARK: - check transaction status
//    func beganStateCheck(walletAddress: String, token: TokenModel) {
//        let result = realm.objects(SentTransaction.self)
//        let list = result.filter { (entity) -> Bool in
//            return entity.from == walletAddress && entity.tokenType == token.type && entity.contractAddress == token.address
//        }
//        transactions.append(contentsOf: list)
//        checkSentTransactionStatus()
//    }

//    func stopStateCheck(walletAddress: String, token: TokenModel) {
//        transactions = transactions.filter({ (entity) -> Bool in
//            return entity.from == walletAddress && entity.tokenType == token.type && entity.contractAddress == token.address
//        })
//    }

    @objc func checkSentTransactionStatus() {
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
                if let idx = self.transactions.index(object: transaction) {
                    self.transactions.remove(at: idx)
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
                }
                if let idx = self.transactions.index(object: transaction) {
                    self.transactions.remove(at: idx)
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

    // MAKR: Utils
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
        let task = Task(block: block)
        let sel = #selector(TransactionStatusManager.taskHandler(task:))
        self.perform(sel, on: self.thread, with: task, waitUntilDone: true)
    }

    @objc private func taskHandler(task: Task) {
        task.block()
    }
//
//    func value<T>(_ block: (TransactionStatusManager) -> T) -> T {
//
//        let value = block(self)
//
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
//            RunLoop.current.run(mode: .default, before: Date.distantPast)
        }
        group.wait()
    }
}



/**
 管理交易状态

 缓存发送的交易信息
 walletAddress tokenType transaction

 开启交易状态检查 - 每隔一定时间查询处于 交易进行中 的交易记录的状态
 指定 walletAddress 、 token 类型
 如果交易成功，发送交易状态变更消息，并从数据库中删除对应记录
 交易失败，从检查列表中移除

 拉取交易记录时，合并相同时间段的 缓存的交易记录（交易进行中、交易失败的）
 需要提供指定时间段内的缓存的交易记录

 切换钱包，变更状态查询列表
 切换Eth网络，变更状态查询列表

 */
