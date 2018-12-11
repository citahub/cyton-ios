//
//  AppChain+TransactionStatus.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain

extension AppChainNetwork {
    func getTransactionStatus(localTxDetail: LocalTxDetailModel) -> TransactionStateResult {
        do {
            let currentBlockNumber = try AppChainNetwork.appChain().rpc.blockNumber()
            if let receipt = try? AppChainNetwork.appChain().rpc.getTransactionReceipt(txhash: localTxDetail.txHash) {
                if let error = receipt.errorMessage {
                    print(error)
                    return .failure
                } else {
                    if let transaction = try? AppChainNetwork().getTransaction(txhash: localTxDetail.txHash, account: localTxDetail.from, from: localTxDetail.from, to: localTxDetail.to) {
                        return .success(transaction: transaction)
                    } else {
                        if localTxDetail.blockNumber < currentBlockNumber {
                            return .failure
                        } else {
                            return .pending
                        }
                    }
                }
            } else {
                if localTxDetail.blockNumber < currentBlockNumber {
                    return .failure
                } else {
                    return .pending
                }
            }
        } catch {
            return .pending
        }
    }
}
