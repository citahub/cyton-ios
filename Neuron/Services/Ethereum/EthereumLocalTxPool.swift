//
//  EthereumLocalTxPool.swift
//  Neuron
//
//  Created by 晨风 on 2018/12/27.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import Web3swift
import struct Web3swift.TransactionDetails
import BigInt

enum TxStatus: Int {
    case pending
    case success
    case failure
}

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
    var ethereumNetwork: EthereumNetwork.EthereumNetworkType! {
        get { return EthereumNetwork.EthereumNetworkType(rawValue: ethereumNetworkValue)! }
        set { ethereumNetworkValue = newValue.rawValue }
    }
    var status: TxStatus! {
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
}

class EthereumLocalTxPool {
    static let didUpdateTxStatus = Notification.Name("didUpdateTxStatus")
    static let didAddLocalTx = Notification.Name("didAddLocalTx")
    static let localTxKey = "localTx"
    static let pool = EthereumLocalTxPool()

    func configure() {}

    func insertLocalTx(localTx: EthereumLocalTx) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(localTx)
            }
            NotificationCenter.default.post(name: EthereumLocalTxPool.didAddLocalTx, object: nil, userInfo: [EthereumLocalTxPool.localTxKey: localTx])
        } catch {
        }
    }

    func getLocalTx(with walletAddress: String, contractAddress: String = "") -> [EthereumLocalTx] {
        let ethereumNetwork = EthereumNetwork().networkType
        return (try! Realm()).objects(EthereumLocalTx.self).filter({
            $0.from == walletAddress &&
            $0.ethereumNetwork == ethereumNetwork &&
            $0.token.address == contractAddress
        })
    }

    // MARK: - Private
    private var observers = [NotificationToken]()

    private init() {
        DispatchQueue.global().async {
            self.checkLocalTxStatus()
        }
        let realm = try! Realm()
        observers.append(realm.objects(EthereumLocalTx.self).observe { (change) in
            switch change {
            case .update(_, deletions: _, let insertions, modifications: _):
                guard insertions.count > 0 else { return }
                DispatchQueue.global().async {
                    self.checkLocalTxStatus()
                }
            default:
                break
            }
        })
    }

    private var checking = false

    private func checkLocalTxStatus() {
        guard checking == false else { return }
        let realm = try! Realm()
        let results = realm.objects(EthereumLocalTx.self).filter({ $0.status == .pending })
        guard results.count > 0 else { return }
        checking = true
        print("Txs 交易进行中 \(results.count)")
        results.forEach { (localTx) in
            guard localTx.status == .pending else { return }
            self.checkLocalTxStatus(localTx: localTx)
        }
        checking = false
        checkLocalTxStatus()
    }

    private func checkLocalTxStatus(localTx: EthereumLocalTx) {
        print("Txs \(localTx.txHash) 开始检查交易状态")
        defer {
            print("Txs zzzzzzzzz")
            if localTx.status == .pending {
                if localTx.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
                    localTx.status = .failure
                    print("Txs \(localTx.txHash) 交易失败(超时)")
                } else {
                    print("Txs \(localTx.txHash) 交易进行中")
                }
            }
        }
        guard let blockNumber = localTx.blockNumber else { return }
        guard let currentBlockNumber = try? localTx.web3.eth.getBlockNumber() else { return }
        let realm = try! Realm()
        try? realm.write {
            let txHash = localTx.txHash
            if localTx.transactionReceipt?.status == .ok {
                if currentBlockNumber - blockNumber < 12 {
                    print("Txs \(localTx.txHash) 检查块高(\(currentBlockNumber - blockNumber))/12")
                    return
                }
                localTx.status = .success
                print("Txs \(localTx.txHash) 交易成功")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: EthereumLocalTxPool.didUpdateTxStatus, object: nil,
                        userInfo: [EthereumLocalTxPool.localTxKey: realm.object(ofType: EthereumLocalTx.self, forPrimaryKey: txHash)!]
                    )
                }
            } else if localTx.transactionReceipt?.status == .failed {
                localTx.status = .failure
                print("Txs \(localTx.txHash) 交易失败")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: EthereumLocalTxPool.didUpdateTxStatus, object: nil,
                        userInfo: [EthereumLocalTxPool.localTxKey: realm.object(ofType: EthereumLocalTx.self, forPrimaryKey: txHash)!]
                    )
                }
            } /*else if localTx.transactionReceipt?.status == .notYetProcessed {
             localTx.status = .pending
             }*/
        }
    }
}

extension EthereumLocalTx {
    private struct AssociatedKey {
        static var transactionDetails: Int = 0
        static var transactionReceipt: Int = 0
    }

    fileprivate var transactionDetails: Web3swift.TransactionDetails? {
        if let transactionDetails = objc_getAssociatedObject(self, &AssociatedKey.transactionDetails) {
            return transactionDetails as? Web3swift.TransactionDetails
        }
        let transactionDetails = try? web3.eth.getTransactionDetails(txHash)
        if transactionDetails?.blockNumber != nil {
            objc_setAssociatedObject(self, &AssociatedKey.transactionDetails, transactionDetails, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return transactionDetails
    }

    fileprivate var transactionReceipt: Web3swift.TransactionReceipt? {
        if let transactionReceipt = objc_getAssociatedObject(self, &AssociatedKey.transactionReceipt) {
            return transactionReceipt as? Web3swift.TransactionReceipt
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
        return tx
    }
}