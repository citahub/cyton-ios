//
//  EthereumLocalTxPool.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/27.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import web3swift
import struct web3swift.TransactionDetails
import BigInt

class EthereumLocalTx: Object {
    @objc dynamic var token: TokenModel!
    @objc dynamic var txHash = ""
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gasPrice = ""
    @objc dynamic var gasLimit = ""
    @objc dynamic var date = Date()
    @objc dynamic private var statusValue: Int = TxStatus.pending.rawValue
    @objc dynamic private var ethereumNetworkValue: String = EthereumNetwork().networkType.rawValue
    var ethereumNetwork: EthereumNetwork.NetworkType {
        get { return EthereumNetwork.NetworkType(rawValue: ethereumNetworkValue)! }
        set { ethereumNetworkValue = newValue.rawValue }
    }
    var status: TxStatus {
        get { return TxStatus(rawValue: statusValue)! }
        set { statusValue = newValue.rawValue }
    }

    required convenience init(token: TokenModel, txHash: String, from: String, to: String, value: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt) {
        self.init()
        self.token = token
        self.txHash = txHash
        self.from = from
        self.to = to
        self.value = String(value)
        self.gasPrice = String(gasPrice)
        self.gasLimit = String(gasLimit)
    }

    @objc override class func primaryKey() -> String? { return "txHash" }

    enum TxStatus: Int {
        case pending
        case success
        case failure
    }
}

class EthereumLocalTxPool: NSObject {
    static let didUpdateTxStatus = Notification.Name("EthereumLocalTxPool.didUpdateTxStatus")
    static let didAddLocalTx = Notification.Name("EthereumLocalTxPool.didAddLocalTx")
    static let txKey = "tx"
    static let pool = EthereumLocalTxPool()

    func register() {}

    func insertLocalTx(localTx: EthereumLocalTx) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(localTx)
            }
            let tx = localTx.getTx()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: EthereumLocalTxPool.didAddLocalTx, object: nil, userInfo: [EthereumLocalTxPool.txKey: tx])
            }
        } catch {
        }
    }

    func getTransactions(token: Token) -> [EthereumTransactionDetails] {
        let ethereumNetwork = EthereumNetwork().networkType
        return (try! Realm()).objects(EthereumLocalTx.self).filter({
            $0.from == token.walletAddress &&
            $0.token.address == token.address &&
            $0.ethereumNetwork == ethereumNetwork
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
        observers.append(realm.objects(EthereumLocalTx.self).observe { (change) in
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
        guard checking == false else { return }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkLocalTxList), object: nil)
        let realm = try! Realm()
        let results = realm.objects(EthereumLocalTx.self).filter({ $0.status == .pending })
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

    private func checkLocalTxStatus(localTx: EthereumLocalTx) {
        guard let blockNumber = localTx.blockNumber else { return }
        guard let currentBlockNumber = try? localTx.web3.eth.getBlockNumber() else { return }
        let realm = try! Realm()
        var status: EthereumLocalTx.TxStatus = .success
        if localTx.transactionReceipt?.status == .ok {
            if Int(currentBlockNumber) - Int(blockNumber) < 12 {
                return
            }
            status = .success
        } else if localTx.transactionReceipt?.status == .failed {
            status = .failure
        }
        if localTx.status == .pending && localTx.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
            status = .failure
        }

        try? realm.write {
            localTx.status = status
        }

        if localTx.status == .success || localTx.status == .failure {
            let tx = localTx.getTx()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: EthereumLocalTxPool.didUpdateTxStatus, object: nil, userInfo: [EthereumLocalTxPool.txKey: tx])
            }
        }
    }
}

extension EthereumLocalTx {
    private struct AssociatedKey {
        static var transactionDetails: Int = 0
        static var transactionReceipt: Int = 0
    }

    fileprivate var transactionDetails: web3swift.TransactionDetails? {
        if let transactionDetails = objc_getAssociatedObject(self, &AssociatedKey.transactionDetails) {
            return transactionDetails as? web3swift.TransactionDetails
        }
        let transactionDetails = try? web3.eth.getTransactionDetails(txHash)
        if transactionDetails?.blockNumber != nil {
            objc_setAssociatedObject(self, &AssociatedKey.transactionDetails, transactionDetails, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return transactionDetails
    }

    fileprivate var transactionReceipt: web3swift.TransactionReceipt? {
        if let transactionReceipt = objc_getAssociatedObject(self, &AssociatedKey.transactionReceipt) {
            return transactionReceipt as? web3swift.TransactionReceipt
        }
        let transactionReceipt = try? web3.eth.getTransactionReceipt(txHash)
        if transactionReceipt?.status == .ok || transactionReceipt?.status == .failed {
            objc_setAssociatedObject(self, &AssociatedKey.transactionReceipt, transactionReceipt, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return transactionReceipt
    }

    fileprivate var blockNumber: BigUInt? {
        return transactionDetails?.blockNumber
    }

    fileprivate var web3: web3 {
        return EthereumNetwork().getWeb3(networkType: ethereumNetwork)
    }
}

extension EthereumLocalTx {
    func getTx() -> EthereumTransactionDetails {
        let tx = EthereumTransactionDetails()
        tx.gasUsed = BigUInt(gasLimit) ?? 0
        tx.contractAddress = token.address
        tx.token = Token(token, from)
        tx.hash = txHash
        tx.from = from
        tx.to = to
        tx.value = BigUInt(value) ?? 0
        tx.gasPrice = BigUInt(gasPrice) ?? 0
        tx.gasLimit = BigUInt(gasLimit) ?? 0
        tx.date = date
        tx.blockNumber = blockNumber ?? 0
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
