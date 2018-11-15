//
//  EthereumTransactionStatus.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class EthereumTransactionStatus: NSObject {
    func getTransactionStatus(sentTransaction: SentTransaction) -> TransactionStateResult {
        do {
            let transaction = try EthereumTransactionHistory().getTransaction(txhash: sentTransaction.txHash)

            let blockNumber = try EthereumNetwork().getWeb3().eth.getBlockNumber()
            if blockNumber - sentTransaction.blockNumber < 12 {
                // 交易进行中
                return .pending
            }

            let receipt = try EthereumNetwork().getWeb3().eth.getTransactionReceipt(sentTransaction.txHash)
            switch receipt.status {
            case .ok:
                return .success(transaction: transaction)
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
