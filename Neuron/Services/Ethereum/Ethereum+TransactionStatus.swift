//
//  Ethereum+TransactionStatus.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import Web3swift

extension EthereumNetwork {
    func getTransactionStatus(localTxDetail: LocalTxDetailModel) -> TransactionStateResult {
        do {
            let transactionDetails = try EthereumNetwork().getWeb3().eth.getTransactionDetails(localTxDetail.txHash) // TODO: cache
            if transactionDetails.blockNumber == 0 || transactionDetails.blockNumber == nil {
                return .pending
            }
            try? localTxDetail.realm?.write {
                localTxDetail.blockNumber = Int(transactionDetails.blockNumber?.words.first ?? 0)
            }

            let blockNumber = try EthereumNetwork().getWeb3().eth.getBlockNumber()
            if blockNumber - BigUInt(localTxDetail.blockNumber) < 12 {
                print("TxS \(blockNumber) - \(BigUInt(localTxDetail.blockNumber))")
                return .pending
            }

            let receipt = try EthereumNetwork().getWeb3().eth.getTransactionReceipt(localTxDetail.txHash)
            switch receipt.status {
            case .ok:
                let details: TransactionDetails = localTxDetail.getTransactionDetails()
                if let ethereumTransaction = details as? EthereumTransactionDetails {
                    ethereumTransaction.nonce = transactionDetails.transaction.nonce
                    ethereumTransaction.blockHash = "0x" + String(BigUInt(receipt.blockHash), radix: 16)
                    ethereumTransaction.transactionIndex = receipt.transactionIndex
                    ethereumTransaction.gasPrice = transactionDetails.transaction.gasPrice
                    ethereumTransaction.gasUsed = receipt.gasUsed
                    ethereumTransaction.cumulativeGasUsed = receipt.cumulativeGasUsed
                } else if let erc20Transaction = details as? Erc20TransactionDetails {
                    erc20Transaction.nonce = transactionDetails.transaction.nonce
                    erc20Transaction.blockHash = "0x" + String(BigUInt(receipt.blockHash), radix: 16)
                    erc20Transaction.transactionIndex = receipt.transactionIndex
                    erc20Transaction.gasPrice = transactionDetails.transaction.gasPrice
                    erc20Transaction.gasUsed = receipt.gasUsed
                    erc20Transaction.cumulativeGasUsed = receipt.cumulativeGasUsed
                }
                details.status = .success
                return .success(transaction: details)
            case .failed:
                return .failure
            case .notYetProcessed:
                if localTxDetail.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
                    return .failure // timeout
                } else {
                    return .pending
                }
            }
        } catch {
            if localTxDetail.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
                return .failure // timeout
            } else {
                return .pending
            }
        }
    }
}
