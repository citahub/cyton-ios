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
import AppChain

class LocationTxDetailsModel: Object {
    var tokenType: TokenType {
        set {
            privateTokenType = newValue.rawValue
        }
        get {
            return TokenType(rawValue: privateTokenType) ?? .appChain
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
    @objc dynamic var chainHosts: String!

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
    required convenience init(tokenType: TokenType, from: String, to: String = "", value: BigUInt = 0, txFee: BigUInt = 0, txHash: TxHash) {
        self.init(contractAddress: "", tokenType: tokenType, from: from, to: to, value: value, txFee: txFee, txHash: txHash)
    }

    // Erc20
    required convenience init(contractAddress: String, tokenType: TokenType, from: String, to: String = "", value: BigUInt = 0, txFee: BigUInt = 0, txHash: TxHash) {
        self.init()
        self.tokenType = tokenType
        self.txHash = txHash
        blockNumber = (try? EthereumNetwork().getWeb3().eth.getTransactionDetails(txHash))?.blockNumber ?? 0
        self.from = from
        self.to = to
        amount = value
        self.txFee = txFee
        self.contractAddress = contractAddress
        status = .pending
        ethereumNetwork = EthereumNetwork().host().absoluteString
    }

    // AppChain
    required convenience init(tokenType: TokenType, from: String, hash: String, transaction: Transaction, chainHosts: String) {
        self.init()
        txHash = hash
        blockNumber = BigUInt(transaction.validUntilBlock)
        self.from = from
        to = transaction.to?.address ?? ""
        amount = transaction.value
        txFee = BigUInt(transaction.quota)
        status = .pending
        self.chainHosts = chainHosts
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
        if tokenType == .ether {
            let ethereum = EthereumTransactionDetails()
            details = ethereum
        } else if tokenType == .erc20 {
            let erc20 = Erc20TransactionDetails()
            erc20.contractAddress = contractAddress
            details = erc20
        } else if tokenType == .appChain {
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

extension LocationTxDetailsModel {
    public static func == (lhs: LocationTxDetailsModel, rhs: LocationTxDetailsModel) -> Bool {
        return lhs.txHash == rhs.txHash
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LocationTxDetailsModel  else {
            return false
        }
        return object.txHash == txHash
    }
}

extension TransactionDetails {
    convenience init(sentTransaction: LocationTxDetailsModel) {
        self.init()
    }
}
