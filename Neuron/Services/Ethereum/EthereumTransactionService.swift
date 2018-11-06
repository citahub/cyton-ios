//
//  EthereumTransactionService.swift
//  Neuron
//
//  Created by James Chen on 2018/11/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

extension TransactionService {
    class Erc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let bigNumber = try Web3Network().getWeb3().eth.getGasPrice()
                self.gasPrice = (bigNumber.words.first ?? 1) * 4
            } catch {
                self.gasPrice = 4
            }
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            ERC20TransactionService().prepareERC20TransactionForSending(
                destinationAddressString: toAddress,
                amountString: "\(amount)",
                gasLimit: gasLimit,
                gasPrice: BigUInt(gasPrice),
                erc20TokenAddress: token.address) { (result) in
                    switch result {
                    case .success(let transaction):
                        ERC20TransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                            switch result {
                            case .success(let result):
                                self.completion(result: Result.ethereum(result))
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
    class Ethereum: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let bigNumber = try Web3Network().getWeb3().eth.getGasPrice()
                self.gasPrice = (bigNumber.words.first ?? 1) * 4
            } catch {
                self.gasPrice = 4
            }
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            EthTransactionService().prepareETHTransactionForSending(
                destinationAddressString: toAddress,
                amountString: "\(amount)",
                gasLimit: gasLimit,
                gasPrice: BigUInt(gasPrice),
                data: extraData) { (result) in
                    switch result {
                    case .success(let transaction):
                        EthTransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                            switch result {
                            case .success(let result):
                                self.completion(result: Result.ethereum(result))
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
