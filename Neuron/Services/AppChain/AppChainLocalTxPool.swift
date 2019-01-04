//
//  AppChainLocalTxPool.swift
//  Neuron
//
//  Created by 晨风 on 2019/1/3.
//  Copyright © 2019 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt
import AppChain

class AppChainLocalTx: Object {
    @objc dynamic var token: TokenModel!
    @objc dynamic var txHash = ""
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var quotaPrice = ""
    @objc dynamic var quotaLimit = ""
    @objc dynamic var date = Date()
    @objc dynamic private var statusValue: Int = TxStatus.pending.rawValue
    @objc dynamic private var blockNumberText = ""
    var status: TxStatus {
        get { return TxStatus(rawValue: statusValue)! }
        set { statusValue = newValue.rawValue }
    }
    var blockNumber: BigUInt {
        get { return BigUInt(blockNumberText)! }
        set { blockNumberText = String(newValue) }
    }

    required convenience init(token: TokenModel, txHash: String, blockNumber: BigUInt, from: String, to: String, value: BigUInt, quotaPrice: BigUInt, quotaLimit: BigUInt) {
        self.init()
        self.token = token
        self.txHash = txHash
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.value = String(value)
        self.quotaPrice = String(quotaPrice)
        self.quotaLimit = String(quotaLimit)
    }

    @objc override class func primaryKey() -> String? { return "txHash" }

    enum TxStatus: Int {
        case pending
        case success
        case failure
    }
}

class AppChainLocalTxPool: NSObject {
    static let didUpdateTxStatus = Notification.Name("AppChainLocalTxPool.didUpdateTxStatus")
    static let didAddLocalTx = Notification.Name("AppChainLocalTxPool.didAddLocalTx")
    static let txKey = "tx"
    static let pool = AppChainLocalTxPool()

    func register() {}

    func insertLocalTx(localTx: AppChainLocalTx) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(localTx)
            }
            NotificationCenter.default.post(name: AppChainLocalTxPool.didAddLocalTx, object: nil, userInfo: [AppChainLocalTxPool.txKey: localTx.getTx()])
        } catch {
        }
    }

    func getTransactions(token: Token) -> [AppChainTransactionDetails] {
        return (try! Realm()).objects(AppChainLocalTx.self).filter({
            $0.from == token.walletAddress &&
            $0.token.address == token.address
        }).map({ $0.getTx() })
    }

    // MARK: - Private
    private var observers = [NotificationToken]()

    private override init() {
        super.init()
        DispatchQueue.global().async {
            self.checkLocalTxList()
        }
        let realm = try! Realm()
        observers.append(realm.objects(AppChainLocalTx.self).observe { (change) in
            switch change {
            case .update(_, deletions: _, let insertions, modifications: _):
                guard insertions.count > 0 else { return }
                DispatchQueue.global().async {
                    self.checkLocalTxList()
                }
            default:
                break
            }
        })
    }

    private var checking = false
    private let timeInterval: TimeInterval = 4.0

    @objc private func checkLocalTxList() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkLocalTxList), object: nil)
        guard checking == false else { return }
        let realm = try! Realm()
        let results = realm.objects(AppChainLocalTx.self).filter({ $0.status == .pending })
        guard results.count > 0 else { return }
        checking = true
        results.forEach { (localTx) in
            guard localTx.status == .pending else { return }
            self.checkLocalTxStatus(localTx: localTx)
        }
        checking = false
        checkLocalTxList()
        perform(#selector(checkLocalTxList), with: nil, afterDelay: timeInterval)
    }

    private func checkLocalTxStatus(localTx: AppChainLocalTx) {
        let appChain = AppChain(provider: HTTPProvider(URL(string: localTx.token.chain.httpProvider)!)!)
        do {
            try (try Realm()).write {
                let currentBlockNumber = try appChain.rpc.blockNumber()
                if let receipt = try? appChain.rpc.getTransactionReceipt(txhash: localTx.txHash) {
                    if receipt.errorMessage != nil {
                        localTx.status = .failure
                    } else {
                        if (try? AppChainNetwork().getTransaction(txhash: localTx.txHash)) != nil {
                            localTx.status = .success
                        }
                    }
                }
                if localTx.status == .pending && localTx.blockNumber < BigUInt(currentBlockNumber) {
                    localTx.status = .failure
                }
            }
        } catch {
        }
        if localTx.status == .success || localTx.status == .failure {
            let tx = localTx.getTx()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: AppChainLocalTxPool.didUpdateTxStatus, object: nil, userInfo: [AppChainLocalTxPool.txKey: tx])
            }
        }
    }
}

extension AppChainLocalTx {
    func getTx() -> AppChainTransactionDetails {
        let tx = AppChainTransactionDetails()
        tx.token = Token(token, from)
        tx.hash = txHash
        tx.from = from
        tx.to = to
        tx.value = BigUInt(value) ?? 0
        tx.quotaUsed = BigUInt(quotaLimit) ?? 0
        tx.date = date
        tx.blockNumber = blockNumber
        switch status {
        case .pending:
            tx.status = .pending
        case .success:
            tx.status = .success
        case .failure:
            tx.status = .failure
        }
        return tx
    }
}

extension AppChainLocalTx {
    private var appChain: AppChain {
        return AppChain(provider: HTTPProvider(URL(string: token.chain.httpProvider)!)!)
    }
}
