//
//  AppChainTransactionStatus.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class AppChainTransactionStatus: NSObject {
    func getTransactionStatus(transaction: LocationTransactionDetails) -> TransactionStateResult {
        do {
            // 查询交易数据
            let details = try AppChainNetwork.appChain().rpc.getTransaction(txhash: transaction.details.hash)
//            let details = try AppChainTransactionHistory().getTransaction(txhash: transaction.hashString, account: transaction.walletAddress, from: tr, to: <#T##String#>)
            print(details)
            // 交易成功
            return .success(transaction: AppChainTransactionDetails())
        } catch {
            do {
                let currentBlockNumber = try AppChainNetwork.appChain().rpc.blockNumber()
                if transaction.details.blockNumber < currentBlockNumber {
                    // 小于当前 block height
                    // 获取打包成功的 receipt
                    if let receipt = try? AppChainNetwork.appChain().rpc.getTransactionReceipt(txhash: transaction.details.hash) {
                        // 交易进行中
                        print(receipt)
                        return .pending
                    } else {
                        // 交易失败
                        return .failure
                    }
                } else {
                    // 交易进行中
                    return .pending
                }
            } catch {
                // 获取 block height 失败
                // 交易进行中
                return .pending
            }
        }
    }
}
