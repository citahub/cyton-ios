//
//  AppChainTransactionService.swift
//  Neuron
//
//  Created by James Chen on 2018/11/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

extension TransactionService {
    class Nervos: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let result = try Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }

        override func sendTransaction() {
            super.sendTransaction()
            NervosTransactionService().prepareNervosTransactionForSending(
                address: toAddress,
                quota: BigUInt(UInt(gasLimit/* * gasPrice*/)),
                data: extraData,
                value: "\(amount)",
                tokenHosts: token.chainHosts,
                chainId: BigUInt(token.chainId)!) { (result) in
                    switch result {
                    case .success(let transaction):
                        NervosTransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                            switch result {
                            case .success(let result):
                                self.completion(result: Result.appChain(result))
                            case .error:
                                self.completion(result: Result.error(.sendFailed))
                            }
                        })
                    case .error:
                        self.completion(result: Result.error(.prepareFailed))
                    }
            }
        }
    }
}


extension TransactionService {
    class NervosErc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 100000
            do {
                let result = try Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }
    }
}
