//
//  EthereumTransactionService.swift
//  Neuron
//
//  Created by James Chen on 2018/11/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress
import Web3swift

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
            EthereumTransactionService().send(
                destinationAddressString: toAddress,
                amountString: "\(amount)",
                gasLimit: gasLimit,
                gasPrice: BigUInt(gasPrice),
                data: extraData,
                password: password
                ) { (result) in
                    switch result {
                    case .success(let transaction):
                        EthereumTransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
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

class EthereumTransactionService {
    func send(
        destinationAddressString: String,
        amountString: String,
        gasLimit: UInt = 21000,
        gasPrice: BigUInt,
        data: Data,
        password: String
    ) throws -> TxHash
    {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
        let keystore = WalletManager.default.keystore(for: wallet.address)

        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
            throw SendEthError.invalidDestinationAddress
        }

        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
            throw SendEthError.invalidAmountFormat
        }

        let web3 = Web3Network().getWeb3()
        web3.addKeystoreManager(KeystoreManager([keystore]))

        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
            throw SendEthError.contractLoadingError
        }

        var options = TransactionOptions()
        options.gasLimit = .limited(BigUInt(gasLimit))
        options.from = EthereumAddress(wallet.address)
        options.value = BigUInt(amount)

        guard let estimatedGas = try? contract.method(transactionOptions: options)!.estimateGas(transactionOptions: nil) else {
            throw SendEthError.retrievingEstimatedGasError
        }
        options.gasLimit = .limited(estimatedGas)
        options.gasPrice = .manual(gasPrice)
        guard let transaction = contract.method(transactionOptions: options) else {
            throw SendEthError.createTransactionIssue
        }

        let result = try transaction.sendPromise(password: password).wait()
        return result.hash
    }
}

extension TransactionService {
    class ERC20: TransactionService {
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
