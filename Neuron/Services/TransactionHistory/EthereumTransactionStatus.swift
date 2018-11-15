//
//  EthereumTransactionStatus.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class EthereumTransactionStatus: NSObject {
    func getTransactionStatus(transaction: LocationTransactionDetails) -> TransactionState {
        do {
            // 查询交易信息
            let transaction = try EthereumNetwork().getWeb3().eth.getTransactionDetails(transaction.details.hash)
            print(transaction)
            // 交易成功
            return .success
        } catch {
            print(error.localizedDescription)
            do {
                let blockHeight = try EthereumNetwork().getWeb3().eth.getBlockNumber()
                if blockHeight - transaction.details.blockNumber < 12 {
                    // 交易进行中
                    return .pending
                } else {
                    let receipt = try EthereumNetwork().getWeb3().eth.getTransactionReceipt(transaction.details.hash)
                    print(receipt)
                    // 交易成功
                    return .success
                }
            } catch {
                print(error.localizedDescription)
                if transaction.details.date.timeIntervalSince1970 + 60*60*48 < Date().timeIntervalSince1970 {
                    // 超时
                    // 交易失败
                    return .failure
                } else {
                    // 交易进行中
                    return .pending
                }
            }
        }
    }
}
