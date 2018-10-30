//
//  EthTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/7.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

class EthTransactionService {
    func prepareETHTransactionForSending(destinationAddressString: String,
                                         amountString: String,
                                         gasLimit: UInt = 21000,
                                         walletPassword: String,
                                         gasPrice: BigUInt,
                                         data: Data,
                                         completion:  @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        guard let keyStoreStr = try? WalletTool.getKeystoreForCurrentWallet(password: walletPassword) else {
            DispatchQueue.main.async {
                completion(SendEthResult.error(SendEthError.invalidPassword))
            }
            return
        }
        let currentWalletAddress = WalletRealmTool.getCurrentAppModel().currentWallet?.address

        DispatchQueue.global().async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.invalidAmountFormat))
                }
                return
            }

            let web3 = Web3Network.getWeb3()
            guard let selectedKey = currentWalletAddress else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.noAvailableKeys))
                }
                return
            }
            let ethAddressFrom = EthereumAddress(selectedKey)

            web3.addKeystoreManager(KeystoreManager([EthereumKeystoreV3(keyStoreStr)!]))
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(gasLimit)
            options.from = ethAddressFrom
            options.value = BigUInt(amount)
            guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.contractLoadingError))
                }
                return
            }

            guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.retrievingEstimatedGasError))
                }
                return
            }
            options.gasLimit = estimatedGas
            options.gasPrice = gasPrice
            guard let transaction = contract.method(extraData: Data(), options: options) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.createTransactionIssue))
                }
                return
            }

            DispatchQueue.main.async {
                completion(SendEthResult.success(transaction))
            }
        }
    }

    func send(password: String, transaction: TransactionIntermediate, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password, options: nil)
            if let error = result.error {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(error))
                }
                return
            }
            guard let value = result.value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.emptyResult))
                }
                return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.success(value))
            }
        }
    }

    func sign(password: String, transaction: TransactionIntermediate, address: String, completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        var transactionIntermediate = transaction
        DispatchQueue.global().async {
            guard let keyStoreStr = try? WalletTool.getKeystoreForCurrentWallet(password: password) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.invalidPassword))
                }
                return
            }
            let web3 = Web3Network.getWeb3()
            web3.addKeystoreManager(KeystoreManager([EthereumKeystoreV3(keyStoreStr)!]))
            try? Web3Signer.signIntermediate(intermediate: &transactionIntermediate, keystore: KeystoreManager([EthereumKeystoreV3(keyStoreStr)!]), account: EthereumAddress(address)!, password: password)
            DispatchQueue.main.async {
                completion(SendEthResult.success(transactionIntermediate))
            }
        }
    }

}
