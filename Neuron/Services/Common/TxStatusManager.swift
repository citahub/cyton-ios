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

class TxStatusManager: NSObject {
    static let manager = TxStatusManager()
    static let didUpdateTxStatus = Notification.Name("didUpdateTxStatus")
    static let didAddLocationTxDetails = Notification.Name("didAddLocationTxDetails")
    static let transactionKey = "transaction"

    private var localTxDetailList = [LocalTxDetailModel]()
    private var taskThread = TaskThread()
    private var realm: Realm!

    private lazy var registerOnce: Void = {
        configureTxStatusManager()
        checkSentTransactionStatus()
    }()

    func register() { _ = registerOnce }

    private func configureTxStatusManager() {
        guard taskThread.thread == nil else { return }
        taskThread.run()
        taskThread.syncPerform {
            self.realm = try! Realm()
            self.localTxDetailList = self.realm.objects(LocalTxDetailModel.self).filter({ (transaction) -> Bool in
                return transaction.status == .pending
            })
        }
    }

    // MARK: - Add transaction
    func insertLocalTxDetail(cetateModelBlock: @escaping () -> LocalTxDetailModel) {
        configureTxStatusManager()
        taskThread.perform {
            let localTxDetail = cetateModelBlock()
            try? self.realm.write {
                self.realm.add(localTxDetail)
            }
            self.localTxDetailList.append(localTxDetail)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: TxStatusManager.didAddLocationTxDetails, object: nil, userInfo: [TxStatusManager.transactionKey: localTxDetail.getTransactionDetails()])
            }
            if self.localTxDetailList.count == 1 {
                self.checkSentTransactionStatus()
            }
        }
    }

    // MARK: - 
    func getTransactions(token: Token) -> [TransactionDetails] {
        return (try! Realm()).objects(LocalTxDetailModel.self).filter({ (localTxDetail) -> Bool in
            if token.type == .erc20 || token.type == .ether {
                if localTxDetail.ethereumHost != EthereumNetwork().apiHost().absoluteString {
                    return false
                }
            }
            return localTxDetail.from == token.walletAddress &&
                localTxDetail.token.chainId == token.chainId &&
                localTxDetail.token.symbol == token.symbol &&
                localTxDetail.token.name == token.name &&
                localTxDetail.token.chainHosts == token.chainHosts
        }).map({ $0.getTransactionDetails() })
    }

    // MARK: - Check transaction status
    private let timeInterval: TimeInterval = 4.0

    @objc private func checkSentTransactionStatus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkSentTransactionStatus), object: nil)
        guard self.localTxDetailList.count > 0 else {
            taskThread.stop()
            return
        }
        guard Thread.current == taskThread.thread else {
            taskThread.perform { self.checkSentTransactionStatus() }
            return
        }
        let localTxDetailList = self.localTxDetailList
        for localTxDetail in localTxDetailList {
            let result: TransactionStateResult
            switch localTxDetail.token.type {
            case .ether:
                result = EthereumNetwork().getTransactionStatus(localTxDetail: localTxDetail)
            case .erc20:
                result = EthereumNetwork().getTransactionStatus(localTxDetail: localTxDetail)
            case .appChain:
                result = AppChainNetwork().getTransactionStatus(localTxDetail: localTxDetail)
            default:
                fatalError()
            }
            switch result {
            case .failure:
                self.localTxDetailList.removeAll { $0 == localTxDetail }
                try? self.realm.write {
                    localTxDetail.status = .failure
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: TxStatusManager.didUpdateTxStatus, object: nil, userInfo: [TxStatusManager.transactionKey: localTxDetail.getTransactionDetails()])
                }
            case .success(let transaction):
                self.localTxDetailList.removeAll { $0 == localTxDetail }
                try? self.realm.write {
                    localTxDetail.status = .success
                    localTxDetail.token = nil
                    realm.delete(localTxDetail)
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: TxStatusManager.didUpdateTxStatus, object: nil, userInfo: [TxStatusManager.transactionKey: transaction])
                }
            case .pending:
                break
            }
        }
        perform(#selector(checkSentTransactionStatus), with: nil, afterDelay: timeInterval)
    }
}
