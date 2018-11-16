//
//  SentTransaction.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/15.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt
import Web3swift
import AppChain

protocol ThreadSafeObject {
}

private var threadSafeReferenceAssiciationKey: Int = 0
private var realmConfigurationAssiciationKey: Int = 0
private var realmThreadAssiciationKey: Int = 0
extension ThreadSafeObject where Self: Object {
    private var threadSafeReference: ThreadSafeReference<Self>? {
        return objc_getAssociatedObject(self, &threadSafeReferenceAssiciationKey) as? ThreadSafeReference<Self>
    }
    private var realmConfiguration: Realm.Configuration? {
        return objc_getAssociatedObject(self, &realmConfigurationAssiciationKey) as? Realm.Configuration
    }
    private var realmThread: Thread? {
        return objc_getAssociatedObject(self, &realmThreadAssiciationKey) as? Thread
    }
    var threadSafe: Self {
        guard let configuration = realmConfiguration, let threadSafeReference = threadSafeReference else {
            fatalError("Need to call `setupThreadSafe`")
        }
        guard realmThread != Thread.current else {
            return self
        }
        let realm = try! Realm(configuration: configuration)
        let object = realm.resolve(threadSafeReference)!
        objc_setAssociatedObject(object, &threadSafeReferenceAssiciationKey, threadSafeReference, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(object, &realmConfigurationAssiciationKey, configuration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(object, &realmThreadAssiciationKey, Thread.current, .OBJC_ASSOCIATION_ASSIGN)
        return object
    }

    func setupThreadSafe() {
        let threadSafeReference = ThreadSafeReference(to: self)
        objc_setAssociatedObject(self, &threadSafeReferenceAssiciationKey, threadSafeReference, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if let realm = self.realm {
            objc_setAssociatedObject(self, &realmConfigurationAssiciationKey, realm.configuration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            fatalError("realm is nil")
        }
        objc_setAssociatedObject(self, &realmThreadAssiciationKey, Thread.current, .OBJC_ASSOCIATION_ASSIGN)
    }
}

class SentTransaction: Object, ThreadSafeObject {
    var tokenType: TokenModel.TokenType {
        set {
            privateTokenType = newValue.rawValue
        }
        get {
            return TokenModel.TokenType(rawValue: privateTokenType) ?? .nervos
        }
    }
    @objc dynamic var contractAddress: String = ""
    @objc dynamic var txHash: String = ""
    var blockNumber: BigUInt {
        set {
            privateBlockNumber = String(newValue)
        }
        get {
            return BigUInt(privateBlockNumber) ?? 0
        }
    }
    var status: TransactionState {
        set {
            privateStatus = newValue.rawValue
        }
        get {
            return TransactionState(rawValue: privateStatus)!
        }
    }
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    var amount: BigUInt {
        set {
            privateAmount = String(newValue)
        }
        get {
            return BigUInt(privateAmount) ?? 0
        }
    }
    var txFee: BigUInt {
        set {
            privateTxFee = String(newValue)
        }
        get {
            return BigUInt(privateTxFee) ?? 0
        }
    }
    @objc dynamic var date: Date = Date()
    @objc dynamic var ethereumNetwork: String = ""

    @objc dynamic private var privateBlockNumber: String = ""
    @objc dynamic private var privateStatus: Int = 0
    @objc dynamic private var privateAmount: String = ""
    @objc dynamic private var privateTxFee: String = ""
    @objc dynamic private var privateTokenType: String = ""

    @objc override class func primaryKey() -> String? { return "txHash" }

    @objc override class func ignoredProperties() -> [String] {
        return ["tokenType", "blockNumber", "status", "amount", "txFee"]
    }

    func readValues() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            _ = child.value
        }
    }

    // Ethereum
    required convenience init(tokenType: TokenModel.TokenType, from: String, sendingResult: Web3swift.TransactionSendingResult) {
        self.init(contractAddress: "", tokenType: tokenType, from: from, sendingResult: sendingResult)
    }
    // Erc20
    required convenience init(contractAddress: String, tokenType: TokenModel.TokenType, from: String, sendingResult: Web3swift.TransactionSendingResult) {
        self.init()
        self.tokenType = tokenType
        txHash = sendingResult.hash
        blockNumber = (try? EthereumNetwork().getWeb3().eth.getTransactionDetails(sendingResult.hash))?.blockNumber ?? 0
        self.from = from
        to = sendingResult.transaction.to.address
        amount = sendingResult.transaction.value
        txFee = sendingResult.transaction.gasPrice * sendingResult.transaction.gasLimit
        self.contractAddress = contractAddress
        status = .pending
        ethereumNetwork = EthereumNetwork().host().absoluteString
    }

    // AppChain
    required convenience init(tokenType: TokenModel.TokenType, from: String, hash: String, transaction: Transaction) {
        self.init()
        txHash = hash
        blockNumber = BigUInt(transaction.validUntilBlock)
        self.from = from
        to = transaction.to?.address ?? ""
        amount = transaction.value
        txFee = BigUInt(transaction.quota)
        status = .pending
    }

    // AppChainErc20

    override var description: String {
        return """
        tokenType: \(tokenType)
        contractAddress: \(contractAddress)
        hash: \(txHash)
        blockNumber: \(blockNumber)
        from: \(from)
        to: \(to)
        amount: \(amount)
        txFee: \(txFee)
        """
    }

    func isSendFromToken(token: TokenModel) -> Bool {
        return token.type == tokenType && contractAddress == token.address
    }

    func transactionDetails() -> TransactionDetails {
        let details: TransactionDetails
        if tokenType == .ethereum {
            let ethereum = EthereumTransactionDetails()
            details = ethereum
        } else if tokenType == .erc20 {
            let erc20 = Erc20TransactionDetails()
            erc20.contractAddress = contractAddress
            details = erc20
        } else if tokenType == .nervos {
            let appChain = AppChainTransactionDetails()
            details = appChain
        } else {
            fatalError()
        }
        details.hash = txHash
        details.to = to
        details.from = from
        details.value = amount
        details.date = date
        details.blockNumber = blockNumber
        details.status = status
        return details
    }
}

extension SentTransaction {
    public static func == (lhs: SentTransaction, rhs: SentTransaction) -> Bool {
        return lhs.txHash == rhs.txHash
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SentTransaction  else {
            return false
        }
        return object.txHash == txHash
    }
}

extension TransactionDetails {
    convenience init(sentTransaction: SentTransaction) {
        self.init()
    }
}
