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

extension TokenModel {
    var identifier: String {
        return "\(address)_\(chainName ?? "")_\(name)"
    }
}

class SentTransaction: Object {
    var tokenType: TokenModel.TokenType {
        set {
            privateTokenType = newValue.rawValue
        }
        get {
            return TokenModel.TokenType(rawValue: privateTokenType) ?? .nervos
        }
    }
    @objc dynamic var contractAddress: String = ""
    @objc dynamic var token: TokenModel!
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
        var result = [String: Any]()
        for child in mirror.children {
            guard let key = child.label else {
                fatalError("Invalid key in child: \(child)")
            }
            result[key] = child.value
        }
        print(result)
    }

    required convenience init(
        token: TokenModel,
        hash: String,
        blockNumber: BigUInt,
        from: String,
        to: String,
        amount: BigUInt,
        txFee: BigUInt
        ) {
        self.init()
        contractAddress = token.identifier
        self.token = token
        txHash = hash
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.amount = amount
        self.txFee = txFee
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
    }

    // AppChain
    required convenience init(from: String, hash: String, transaction: Transaction) {
        self.init()
        txHash = hash
        blockNumber = BigUInt(transaction.validUntilBlock)
        self.from = from
        to = transaction.to?.address ?? ""
        amount = transaction.value
        txFee = BigUInt(transaction.quota)
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

    func isSendingFromToken(token: TokenModel) -> Bool {
        return true
    }
}

extension TransactionDetails {
    convenience init(sentTransaction: SentTransaction) {
        self.init()
    }
}
