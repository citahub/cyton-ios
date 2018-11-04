//
//  EthTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/7.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import struct BigInt.BigUInt

class EthTransactionService {
    func prepareETHTransactionForSending(destinationAddressString: String,
                                         amountString: String,
                                         gasLimit: UInt = 21000,
                                         gasPrice: BigUInt,
                                         data: Data,
                                         completion:  @escaping (SendEthResult<WriteTransaction>) -> Void) {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
        let keystore = WalletManager.default.keystore(for: wallet.address)

        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
            return completion(SendEthResult.error(SendEthError.invalidDestinationAddress))
        }

        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
            return completion(SendEthResult.error(SendEthError.invalidAmountFormat))
        }

        DispatchQueue.global().async {
            let web3 = Web3Network().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.contractLoadingError))
                }
                return
            }

            var options = TransactionOptions()
            options.gasLimit = .limited(BigUInt(gasLimit))
            options.from = EthereumAddress(wallet.address)
            options.value = BigUInt(amount)

            guard let estimatedGas = try? contract.method(transactionOptions: options)!.estimateGas(transactionOptions: nil) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.error(SendEthError.retrievingEstimatedGasError))
                }
                return
            }
            options.gasLimit = .limited(estimatedGas)
            options.gasPrice = .manual(gasPrice)
            guard let transaction = contract.method(transactionOptions: options) else {
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
/*
    func sign(password: String, transaction: WriteTransaction, address: String, completion: @escaping (SendEthResult<WriteTransaction>) -> Void) {
        var transactionIntermediate = transaction
        DispatchQueue.global().async {
            let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
            let keystore = WalletManager.default.keystore(for: wallet.address)
            try? Web3Signer.signIntermediate(intermediate: &transactionIntermediate, keystore: KeystoreManager([keystore]), account: EthereumAddress(address)!, password: password)
            DispatchQueue.main.async {
                completion(SendEthResult.success(transactionIntermediate))
            }
        }
    }*/
}
