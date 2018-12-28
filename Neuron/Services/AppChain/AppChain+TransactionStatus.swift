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
            let appChain = AppChainNetwork.appChain(url: URL(string: localTxDetail.token.chain.httpProvider)!)
            let currentBlockNumber = try appChain.rpc.blockNumber()
            if let receipt = try? appChain.rpc.getTransactionReceipt(txhash: localTxDetail.txHash) {
                if let error = receipt.errorMessage {
                    print(error)
                    return .failure
                } else {
                    if (try? AppChainNetwork().getTransaction(txhash: localTxDetail.txHash)) != nil {
                        let details = localTxDetail.getTransactionDetails()
                        details.status = .success
                        return .success(transaction: details)
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
