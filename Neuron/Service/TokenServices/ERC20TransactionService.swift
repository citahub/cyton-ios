//
//  ERC20TransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/7.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol Erc20TransactionServiceProtocol {

    func prepareERC20TransactionForSending(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: UInt,
                                           walletPassword: String,
                                           gasPrice: BigUInt,
                                           erc20TokenAddress: String,
                                           completion:  @escaping (SendEthResult<TransactionIntermediate>) -> Void)
    func send(password: String, transaction: TransactionIntermediate, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void)
}

class ERC20TransactionServiceImp: Erc20TransactionServiceProtocol {
    func prepareERC20TransactionForSending(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: UInt = 21000,
                                           walletPassword: String,
                                           gasPrice: BigUInt,
                                           erc20TokenAddress: String,
                                           completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        let keyStoreStr = WalletCryptoService.didCheckoutKeystoreWithCurrentWallet(password: walletPassword)
        let currentWalletAddress = WalletRealmTool.getCurrentAppmodel().currentWallet?.address

        DispatchQueue.global(qos: .userInitiated).async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidDestinationAddress))
                }
                return
            }
            guard Web3.Utils.parseToBigUInt(amountString, units: .eth) != nil else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                }
                return
            }

            let web3 = Web3Network.getWeb3()
            web3.addKeystoreManager(KeystoreManager([EthereumKeystoreV3(keyStoreStr)!]))
            let token = erc20TokenAddress
//            let contract = self.contract(ERC20Token: token)
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(gasLimit)
            options.gasPrice = gasPrice
            options.from = EthereumAddress(currentWalletAddress!)
            guard let tokenAddress = EthereumAddress(token),
                let fromAddress = EthereumAddress(currentWalletAddress!),
                let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress: tokenAddress, from: fromAddress, to: destinationEthAddress, amount: amountString)
                else {
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(SendEthErrors.createTransactionIssue))
                    }
                    return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(intermediate))
            }
        }
    }

    func send(password: String, transaction: TransactionIntermediate, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password, options: nil)
            if let error = result.error {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(error))
                }
                return
            }
            guard let value = result.value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.emptyResult))
                }
                return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(value))
            }
        }
    }

//    private func contract(ERC20Token:String) -> web3.web3contract? {
//        let web3 = Web3NetWork.getWeb3()
//        guard let contractETHAddress = EthereumAddress(ERC20Token) else {
//            return nil
//        }
//        return web3.contract(Web3.Utils.erc20ABI,at:contractETHAddress,abiVersion:2)
//    }
}
