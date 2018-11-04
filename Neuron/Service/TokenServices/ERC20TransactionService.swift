//
//  ERC20TransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/7.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import struct BigInt.BigUInt

class ERC20TransactionService {
    func prepareERC20TransactionForSending(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: UInt = 21000,
                                           gasPrice: BigUInt,
                                           erc20TokenAddress: String,
                                           completion: @escaping (SendEthResult<WriteTransaction>) -> Void) {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
        let keystore = WalletManager.default.keystore(for: wallet.address)

        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
            return completion(SendEthResult.error(SendEthError.invalidDestinationAddress))
        }

        guard Web3.Utils.parseToBigUInt(amountString, units: .eth) != nil else {
            return completion(SendEthResult.error(SendEthError.invalidAmountFormat))
        }

        guard let tokenAddress = EthereumAddress(erc20TokenAddress), let fromAddress = EthereumAddress(wallet.address) else {
            return completion(SendEthResult.error(SendEthError.createTransactionIssue))
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = Web3Network().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(gasLimit)
            options.gasPrice = gasPrice
            options.from = fromAddress

            do {
                guard let intermediate = try web3.eth.sendERC20tokensWithNaturalUnits(
                    tokenAddress: tokenAddress,
                    from: fromAddress,
                    to: destinationEthAddress,
                    amount: amountString
                ) else {
                    throw SendEthError.createTransactionIssue
                }
                DispatchQueue.main.async {
                    completion(SendEthResult.success(intermediate))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.createTransactionIssue))
                }
            }
        }
    }

    func send(password: String, transaction: WriteTransaction, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try transaction.sendPromise(password: password, transactionOptions: nil).wait()
                DispatchQueue.main.async {
                    completion(SendEthResult.success(result))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(error))
                }
            }
        }
    }
}
