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

class LocalTxDetailModel: Object {
    @objc dynamic var token: TokenModel!
    @objc dynamic var txHash = ""
    @objc dynamic var blockNumber: Int = 0
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = "0"
    @objc dynamic var gasPrice = "0"
    @objc dynamic var gasLimit = "0"
    @objc dynamic var ethereumHost = ""
    @objc dynamic var contractAddress: String = ""

    var status: TransactionState {
        set { privateStatus = newValue.rawValue }
        get { return TransactionState(rawValue: privateStatus)! }
    }

    var date: Date = Date()
    @objc dynamic private var privateStatus: Int = 0

    @objc override class func primaryKey() -> String? { return "txHash" }

    @objc override class func ignoredProperties() -> [String] {
        return ["status"]
    }

    // Ethereum
    required convenience init(tokenIdentifier: String, txHash: TxHash, from: String, to: String, value: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt) {
        self.init()
        self.token = (try! Realm()).object(ofType: TokenModel.self, forPrimaryKey: tokenIdentifier)
        self.txHash = txHash
        blockNumber = Int((try? EthereumNetwork().getWeb3().eth.getTransactionDetails(txHash))?.blockNumber?.words.first ?? 0)
        self.from = from
        self.to = to
        self.value = String(value)
        self.gasPrice = String(gasPrice)
        self.gasLimit = String(gasLimit)
        status = .pending
        ethereumHost = EthereumNetwork().apiHost().absoluteString
    }

    // Erc20
    required convenience init(contractAddress: String, tokenIdentifier: String, txHash: TxHash, from: String, to: String, value: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt) {
        self.init(tokenIdentifier: tokenIdentifier, txHash: txHash, from: from, to: to, value: value, gasPrice: gasPrice, gasLimit: gasLimit)
        self.contractAddress = contractAddress
    }

    // AppChain
    required convenience init(tokenIdentifier: String, txHash: TxHash, from: String, to: String, value: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt, blockNumber: BigUInt) {
        self.init()
        self.token = (try! Realm()).object(ofType: TokenModel.self, forPrimaryKey: tokenIdentifier)
        self.txHash = txHash
        self.blockNumber = Int(blockNumber.words.first ?? 0)
        self.from = from
        self.to = to
        self.value = String(value)
        self.gasPrice = String(gasPrice)
        self.gasLimit = String(gasLimit)
        status = .pending
    }

    // TODO: AppChainErc20

    override var description: String {
        return """
        tokenType: \(token.type)
        contractAddress: \(contractAddress)
        hash: \(txHash)
        blockNumber: \(blockNumber)
        from: \(from)
        to: \(to)
        value: \(value)
        """
    }

    func getTransactionDetails() -> TransactionDetails {
        let transaction: TransactionDetails
        if token.type == .ether {
            let ethereum = EthereumTransactionDetails()
            transaction = ethereum
        } else if token.type == .erc20 {
            let erc20 = Erc20TransactionDetails()
            erc20.contractAddress = contractAddress
            transaction = erc20
        } else if token.type == .appChain {
            let appChain = AppChainTransactionDetails()
            transaction = appChain
        } else {
            fatalError()
        }
        transaction.token = Token(token)
        transaction.token.walletAddress = from
        transaction.hash = txHash
        transaction.to = to
        transaction.from = from
        transaction.value = BigUInt(value)!
        transaction.gasPrice = BigUInt(gasPrice) ?? 0
        transaction.gasLimit = BigUInt(gasLimit) ?? 0
        transaction.date = date
        transaction.blockNumber = BigUInt(blockNumber)
        transaction.status = status
        return transaction
    }
}

extension LocalTxDetailModel {
    public static func == (lhs: LocalTxDetailModel, rhs: LocalTxDetailModel) -> Bool {
        return lhs.txHash == rhs.txHash
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LocalTxDetailModel  else {
            return false
        }
        return object.txHash == txHash
    }
}
