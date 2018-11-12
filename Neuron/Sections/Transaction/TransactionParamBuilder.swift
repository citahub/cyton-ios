//
//  TransactionParamBuilder.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import Web3swift
import BigInt

protocol TransactionParamBuilderDelegate: NSObjectProtocol {
    func transactionCompletion(_ transactionService: TransactionParamBuilder, result: TransactionParamBuilder.Result)
    func transactionGasCostChanged(_ transactionService: TransactionParamBuilder)
}

class TransactionParamBuilder {
    enum Result {
        case error(Error)
        case succee(TxHash)
    }

    weak var delegate: TransactionParamBuilderDelegate?
    var token: TokenModel!
    var fromAddress: String!
    var tokenBalance: Double = 0.0
    var gasPrice: UInt = 1 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(gasLimit) * BigUInt(gasPrice), toUnits: .eth, decimals: 10) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasLimit: UInt64 = 0 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(gasLimit) * BigUInt(gasPrice), toUnits: .eth, decimals: 10) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasCost: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.transactionGasCostChanged(self)
            }
        }
    }
    var gasCostAmount: Double = 0.0
    var changeGasLimitEnable = false
    var changeGasPriceEnable = false
    var isSupportGasSetting: Bool { return changeGasPriceEnable || changeGasLimitEnable }
    var toAddress = ""
    var amount = 0.0 // Change to BigUInt representing final value (smallet unit, e.g., wei).
    var extraData = Data()
    var estimatedGasPrice: UInt = 1 {
        didSet {
            gasPrice = estimatedGasPrice
        }
    }

    init(token: TokenModel) {
        self.token = token
        tokenBalance = Double(token.tokenBalance) ?? 0.0
    }

    static func service(with token: TokenModel) -> TransactionParamBuilder {
        if token.type == .erc20 {
            return ERC20(token: token)
        } else if token.type == .ethereum {
            return Ethereum(token: token)
        } else if token.type == .nervos {
            return AppChain(token: token)
        } else if token.type == .nervosErc20 {
            return AppChainERC20(token: token)
        } else {
            fatalError()
        }
    }

    func requestGasCost() {
    }

    func sendTransaction(password: String) {
    }

    func completion(result: Result) {
        DispatchQueue.main.async {
            self.delegate?.transactionCompletion(self, result: result)
        }
    }
}

extension TransactionParamBuilder {
    class Ethereum: TransactionParamBuilder {
        override func requestGasCost() {
            self.gasLimit = 21_000
            /*
            GasCalculator.getGasPrice { price in
                self.gasPrice = price
            }*/
            let bigNumber = try? EthereumNetwork().getWeb3().eth.getGasPrice()
            estimatedGasPrice = (bigNumber?.words.first ?? 1) * 4
            changeGasLimitEnable = true
            changeGasPriceEnable = false
        }

        override func sendTransaction(password: String) {
            // TODO: extract this
            let keystore = WalletManager.default.keystore(for: fromAddress)
            let web3 = EthereumNetwork().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            do {
                // TODO: change amount to string which matches UI input exactly.
                guard let value = Web3.Utils.parseToBigUInt(String(amount), units: .eth) else {
                    throw SendTransactionError.invalidAmountFormat
                }

                let sender = try EthereumTxSender(web3: web3, from: fromAddress)
                let txhash = try sender.sendETH(
                    to: toAddress,
                    value: value,
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    data: extraData,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

extension TransactionParamBuilder {
    class ERC20: TransactionParamBuilder {
        override func requestGasCost() {
            self.gasLimit = 21_000
            let bigNumber = try? EthereumNetwork().getWeb3().eth.getGasPrice()
            estimatedGasPrice = (bigNumber?.words.first ?? 1) * 4
            changeGasLimitEnable = true
            changeGasPriceEnable = false
        }

        override func sendTransaction(password: String) {
            let keystore = WalletManager.default.keystore(for: fromAddress)
            let web3 = EthereumNetwork().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            do {
                // TODO: Get token decimal and convert
                guard let value = Web3.Utils.parseToBigUInt(String(amount), units: .eth) else {
                    throw SendTransactionError.invalidAmountFormat
                }

                let sender = try EthereumTxSender(web3: web3, from: fromAddress)
                // TODO: estimate gas
                let txhash = try sender.sendToken(
                    to: toAddress,
                    value: value,
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    contractAddress: token.address,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

extension TransactionParamBuilder {
    class AppChain: TransactionParamBuilder {
        override func requestGasCost() {
            self.gasLimit = 21_000
            let quotaPrice = try? Utils.getQuotaPrice(appChain: AppChainNetwork.appChain())
            estimatedGasPrice = quotaPrice?.words.first ?? 1
            changeGasLimitEnable = false
            changeGasPriceEnable = false
        }

        override func sendTransaction(password: String) {
            super.sendTransaction(password: password)
            do {
                guard let appChainUrl = URL(string: token.chainHosts) else {
                    throw SendTransactionError.invalidAppChainNode
                }
                guard let value = Web3Utils.parseToBigUInt(String(amount), units: .eth) else {
                    throw SendTransactionError.invalidAmountFormat
                }
                let sender = try AppChainTxSender(appChain: AppChainNetwork.appChain(url: appChainUrl), walletManager: WalletManager.default, from: fromAddress)
                let txhash = try sender.send(
                    to: toAddress,
                    value: value,
                    quota: gasLimit,
                    data: extraData,
                    chainId: BigUInt(token.chainId)!,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

extension TransactionParamBuilder {
    class AppChainERC20: TransactionParamBuilder {
        override func requestGasCost() {
            self.gasLimit = 100_000
            let bigNumber = try? Utils.getQuotaPrice(appChain: AppChainNetwork.appChain())
            estimatedGasPrice = bigNumber?.words.first ?? 1
            changeGasLimitEnable = false
            changeGasPriceEnable = false
        }
    }
}
