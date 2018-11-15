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

enum TransactionStateResult {
    case pending
    case success(transaction: TransactionDetails)
    case failure
}

class LocationTransactionDetails: Object {
    @objc dynamic var walletAddress: String = ""
    @objc dynamic var tokenIdentifier: String = ""
    @objc dynamic var detailsData: Data!
//    @objc dynamic var token: TokenModel!
    var details: TransactionDetails!
//    {
//        set {
//            privateDetails = newValue
//            detailsData = try? JSONEncoder().encode(privateDetails)
//        }
//        get {
//            return privateDetails
//        }
//    }
//    private lazy var privateDetails: TransactionDetails = {
////        JSONDecoder().decode(TransactionDetails.self, from: <#T##Data#>)
//        return TransactionDetails()
//    }()
}

class TransactionStatusManager: NSObject {
    static let transactionStatusChangedNotification = Notification.Name("transactionStatusChangedNotification")
    static let service = TransactionStatusManager()
    private let timeInterval: TimeInterval = 20.0
    private let realm: Realm
    private var transactions = [LocationTransactionDetails]()

    private override init() {
        let document = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
        let fileURL = document.appendingPathComponent("transaction_history")
        realm = try! Realm(fileURL: fileURL)
        super.init()

//        realm.objects(SentTransactionEntity.sealf).observe { (change) in
//            switch change {
//            case .initial(let list):
//                break
//            case .update(let list, let deletions, let insertions, let modifications):
//                break
//            case .error(let error):
//                print(error.localizedDescription)
//            }
//        }
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

    func insertTransaction(walletAddress: String, tokenIdentifier: String, transaction: LocationTransactionDetails) {
        try? realm.write {
            let transaction = realm.create(LocationTransactionDetails.self)
            realm.add(transaction)
            realm.create(LocationTransactionDetails.self, value: [], update: true)
        }
    }

//    func mergeTransactions(from transactions: [TransactionDetails]) -> [TransactionDetails] {
//        return transactions
//    }

    func getTransactions(walletAddress: String, tokenIdentifier: String) -> [LocationTransactionDetails] {
        return realm.objects(LocationTransactionDetails.self).filter { (entity) -> Bool in
            return entity.walletAddress == walletAddress && entity.tokenIdentifier == entity.tokenIdentifier
        }.shuffled()
    }

    // MARK: - check transaction status
    func beganStateCheck(walletAddress: String, tokenIdentifier: String) {
        let result = realm.objects(LocationTransactionDetails.self)
        let list = result.filter { (entity) -> Bool in
            return entity.walletAddress == walletAddress && entity.tokenIdentifier == tokenIdentifier
        }
        transactions.append(contentsOf: list)
        checkSentTransactionStatus()
    }

    func stopStateCheck(walletAddress: String, tokenIdentifier: String) {
        transactions = transactions.filter({ (entity) -> Bool in
            return entity.walletAddress != walletAddress && entity.tokenIdentifier != tokenIdentifier
        })
    }

    @objc func checkSentTransactionStatus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkSentTransactionStatus), object: nil)
        let transactions = self.transactions
        for transaction in transactions {
            let result = AppChainTransactionStatus().getTransactionStatus(transaction: transaction)
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    try? self.realm.write {
                        transaction.details.status = .failure
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
        if self.transactions.count > 0 {
            perform(#selector(checkSentTransactionStatus), with: nil, afterDelay: timeInterval)
        }
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
