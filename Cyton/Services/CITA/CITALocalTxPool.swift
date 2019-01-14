//
//  CitaLocalTxPool.swift
//  Cyton
//
//  Created by 晨风 on 2019/1/3.
//  Copyright © 2019 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt
import CITA

class CITALocalTx: Object {
    @objc dynamic var token: TokenModel!
    @objc dynamic var txHash = ""
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var quotaPrice = ""
    @objc dynamic var quotaLimit = ""
    @objc dynamic var date = Date()
    @objc dynamic private var statusValue: Int = TxStatus.pending.rawValue
    @objc dynamic private var validUntilBlockText = ""
    var status: TxStatus {
        get { return TxStatus(rawValue: statusValue)! }
        set { statusValue = newValue.rawValue }
    }
    var validUntilBlock: BigUInt {
        get { return BigUInt(validUntilBlockText)! }
        set { validUntilBlockText = String(newValue) }
    }

    required convenience init(token: TokenModel, txHash: String, validUntilBlock: BigUInt, from: String, to: String, value: BigUInt, quotaPrice: BigUInt, quotaLimit: BigUInt) {
        self.init()
        self.token = token
        self.txHash = txHash
        self.validUntilBlock = validUntilBlock
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

class CITALocalTxPool: NSObject {
    static let didUpdateTxStatus = Notification.Name("CITALocalTxPool.didUpdateTxStatus")
    static let didAddLocalTx = Notification.Name("CITALocalTxPool.didAddLocalTx")
    static let txKey = "tx"
    static let pool = CITALocalTxPool()

    func register() {}

    func insertLocalTx(localTx: CITALocalTx) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(localTx)
            }
            let tx = localTx.getTx()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CITALocalTxPool.didAddLocalTx, object: nil, userInfo: [CITALocalTxPool.txKey: tx])
            }
        } catch {
        }
    }

    func getTransactions(token: Token) -> [CITATransactionDetails] {
        return (try! Realm()).objects(CITALocalTx.self).filter({
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
        observers.append(realm.objects(CITALocalTx.self).observe { (change) in
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
        let results = realm.objects(CITALocalTx.self).filter({ $0.status == .pending })
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

    private func checkLocalTxStatus(localTx: CITALocalTx) {
        let cita = CITA(provider: HTTPProvider(URL(string: localTx.token.chain.httpProvider)!)!)
        let realm = try! Realm()
        do {
            try realm.write {
                if let receipt = localTx.transactionReceipt {
                    if receipt.errorMessage != nil {
                        localTx.status = .failure
                    } else {
                        if (try? CITANetwork().getTransaction(txhash: localTx.txHash)) != nil {
                            localTx.status = .success
                        }
                    }
                }
                let currentBlockNumber = try cita.rpc.blockNumber()
                if localTx.status == .pending && localTx.validUntilBlock < BigUInt(currentBlockNumber) {
                    localTx.status = .failure
                }
            }
        } catch {
        }
        if localTx.status == .success || localTx.status == .failure {
            let tx = localTx.getTx()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CITALocalTxPool.didUpdateTxStatus, object: nil, userInfo: [CITALocalTxPool.txKey: tx])
            }
            if localTx.status == .success {
                try? realm.write {
                    realm.delete(localTx)
                }
            }
        }
    }
}

extension CITALocalTx {
    func getTx() -> CITATransactionDetails {
        let tx = CITATransactionDetails()
        tx.token = Token(token, from)
        tx.hash = txHash
        tx.from = from
        tx.to = to
        tx.value = BigUInt(value) ?? 0
        tx.gasLimit = BigUInt(quotaLimit) ?? 0
        tx.date = date
        tx.blockNumber = transactionReceipt?.blockNumber ?? 0
        tx.quotaUsed = transactionReceipt?.quotaUsed ?? 0
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

extension CITALocalTx {
    private struct AssociatedKey {
        static var transactionReceipt = 0
    }

    private var cita: CITA {
        return CITA(provider: HTTPProvider(URL(string: token.chain.httpProvider)!)!)
    }

    fileprivate var transactionReceipt: TransactionReceipt? {
        if let transactionReceipt = objc_getAssociatedObject(self, &AssociatedKey.transactionReceipt) {
            return transactionReceipt as? TransactionReceipt
        }
        let transactionReceipt = try? cita.rpc.getTransactionReceipt(txhash: txHash)
        objc_setAssociatedObject(self, &AssociatedKey.transactionReceipt, transactionReceipt, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return transactionReceipt
    }
}
