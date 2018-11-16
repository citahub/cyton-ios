//
//  EthereumTransactionStatus.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import Web3swift

extension SentTransaction {
    var ethereumTransactionDetails: Web3swift.TransactionDetails? {
        return nil
    }
}

class EthereumTransactionStatus: NSObject {
    func getTransactionStatus(sentTransaction: SentTransaction) -> TransactionStateResult {
        do {
            let transaction = try EthereumNetwork().getWeb3().eth.getTransactionDetails(sentTransaction.txHash)
            let blockNumber = try EthereumNetwork().getWeb3().eth.getBlockNumber()
            if blockNumber - sentTransaction.blockNumber < 12 {
                return .pending
            }

            let receipt = try EthereumNetwork().getWeb3().eth.getTransactionReceipt(sentTransaction.txHash)
            switch receipt.status {
            case .ok:
                var details: TransactionDetails!
                switch sentTransaction.tokenType {
                case .ethereum:
                    let ethereumTransaction = EthereumTransactionDetails()
                    ethereumTransaction.nonce = transaction.transaction.nonce
                    ethereumTransaction.blockHash = "0x" + String(BigUInt(receipt.blockHash), radix: 16)
                    ethereumTransaction.transactionIndex = receipt.transactionIndex
                    ethereumTransaction.gasUsed = receipt.gasUsed
                    ethereumTransaction.cumulativeGasUsed = receipt.cumulativeGasUsed
                    details = ethereumTransaction

                case .erc20:
                    let erc20Transaction = Erc20TransactionDetails()
                    erc20Transaction.nonce = transaction.transaction.nonce
                    erc20Transaction.blockHash = "0x" + String(BigUInt(receipt.blockHash), radix: 16)
                    erc20Transaction.transactionIndex = receipt.transactionIndex
                    erc20Transaction.gasUsed = receipt.gasUsed
                    erc20Transaction.cumulativeGasUsed = receipt.cumulativeGasUsed
                    details = erc20Transaction
                default:
                    fatalError()
                }
                details.hash = sentTransaction.txHash
                details.to = sentTransaction.to
                details.from = sentTransaction.from
                details.value = sentTransaction.amount
                details.date = sentTransaction.date
                details.blockNumber = sentTransaction.blockNumber
                details.status = .success

                return .success(transaction: details)
            case .failed:
                return .failure
            case .notYetProcessed:
                if sentTransaction.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
                    return .failure // timeout
                } else {
                    return .pending
                }
            }
        } catch {
            if sentTransaction.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
                return .failure // timeout
            } else {
                return .pending
            }
        }
    }
}
