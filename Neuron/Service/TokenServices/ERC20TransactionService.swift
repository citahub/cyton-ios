//
//  ERC20TransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/7.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

class ERC20TransactionService {
    func prepareERC20TransactionForSending(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: UInt = 21000,
                                           walletPassword: String,
                                           gasPrice: BigUInt,
                                           erc20TokenAddress: String,
                                           completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        guard let keyStoreStr = try? WalletCryptoService.getKeystoreForCurrentWallet(password: walletPassword) else {
            DispatchQueue.main.async {
                completion(SendEthResult.error(SendEthError.invalidPassword))
            }
            return
        }
        let currentWalletAddress = WalletRealmTool.getCurrentAppModel().currentWallet?.address

        DispatchQueue.global(qos: .userInitiated).async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.invalidDestinationAddress))
                }
                return
            }
            guard Web3.Utils.parseToBigUInt(amountString, units: .eth) != nil else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.invalidAmountFormat))
                }
                return
            }

            let web3 = Web3Network.getWeb3()
            web3.addKeystoreManager(KeystoreManager([EthereumKeystoreV3(keyStoreStr)!]))
            let token = erc20TokenAddress
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(gasLimit)
            options.gasPrice = gasPrice
            options.from = EthereumAddress(currentWalletAddress!)
            guard let tokenAddress = EthereumAddress(token),
                let fromAddress = EthereumAddress(currentWalletAddress!),
                let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress: tokenAddress, from: fromAddress, to: destinationEthAddress, amount: amountString)
                else {
                    DispatchQueue.main.async {
                        completion(SendEthResult.error(SendEthError.createTransactionIssue))
                    }
                    return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.success(intermediate))
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
}
