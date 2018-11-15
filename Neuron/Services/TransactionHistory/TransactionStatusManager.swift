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

protocol TransactionStatusManagerDelegate: NSObjectProtocol {
    func transaction(transaction: TransactionDetails, didChangeStatus: TransactionState)
}

class TransactionStatusManager: NSObject {
    static let transactionStatusChangedNotification = Notification.Name("transactionStatusChangedNotification")
    static let manager = TransactionStatusManager()
    private let timeInterval: TimeInterval = 20.0
    private let realm: Realm
    private var transactions = [SentTransaction]()
    private let delegates: NSHashTable<NSObject>!

    private override init() {
        let document = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
        let fileURL = document.appendingPathComponent("transaction_history")
//        try? FileManager.default.removeItem(at: fileURL)
        realm = try! Realm(fileURL: fileURL)
        let objects = realm.objects(SentTransaction.self)
        transactions = objects.map { (transaction) -> SentTransaction in
            transaction.setupThreadSafe()
            return transaction
        }
//
//        let trans = transactions.first!
//        DispatchQueue.global().async {
//            print(trans.threadSafe.tokenType)
//        }

        delegates = NSHashTable(options: .weakMemory)
        super.init()
        checkSentTransactionStatus()
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
        try? realm.write {
            realm.add(transaction)
//            realm.create(LocationTransactionDetails.self, value: [], update: true)
        }
        transactions.append(transaction)
    }

//    func mergeTransactions(from transactions: [TransactionDetails]) -> [TransactionDetails] {
//        return transactions
//    }

    func getTransactions(walletAddress: String, token: TokenModel) -> [SentTransaction] {
        return realm.objects(SentTransaction.self).filter { (entity) -> Bool in
            return entity.from == walletAddress && entity.tokenType == token.type && entity.contractAddress == token.address
        }.shuffled()
    }

    // MARK: - check transaction status
    func beganStateCheck(walletAddress: String, token: TokenModel) {
        let result = realm.objects(SentTransaction.self)
        let list = result.filter { (entity) -> Bool in
            return entity.from == walletAddress && entity.tokenType == token.type && entity.contractAddress == token.address
        }
        transactions.append(contentsOf: list)
        checkSentTransactionStatus()
    }

    func stopStateCheck(walletAddress: String, token: TokenModel) {
        transactions = transactions.filter({ (entity) -> Bool in
            return entity.from == walletAddress && entity.tokenType == token.type && entity.contractAddress == token.address
        })
    }

    @objc func checkSentTransactionStatus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkSentTransactionStatus), object: nil)
        guard self.transactions.count > 0 else { return }
        guard !Thread.isMainThread else {
            DispatchQueue.global().async {
                self.checkSentTransactionStatus()
            }
            return
        }

        let transactions = self.transactions
        for transaction in transactions {
            let result: TransactionStateResult
            switch transaction.threadSafe.tokenType {
            case .ethereum:
                result = EthereumTransactionStatus().getTransactionStatus(sentTransaction: transaction)
            default:
                fatalError()
            }
//            let result = AppChainTransactionStatus().getTransactionStatus(transaction: transaction)
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    try? self.realm.write {
                        transaction.status = .failure
                        self.realm.add(transaction, update: true)
                    }
                }
            case .success(_):
                DispatchQueue.main.async {
                    try? self.realm.write {
                        self.realm.delete(transaction)
                    }
                }
            case .pending:
                break
            }
        }
        perform(#selector(checkSentTransactionStatus), with: nil, afterDelay: timeInterval)
    }

    // MAKR: Utils

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
