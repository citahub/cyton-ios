//
//  EthereumTxSender.swift
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
                let bigNumber = try EthereumNetwork().getWeb3().eth.getGasPrice()
                self.gasPrice = (bigNumber.words.first ?? 1) * 4
            } catch {
                self.gasPrice = 4
            }
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            do {
                let txhash = try EthereumTxSender().sendETH(
                    to: toAddress,
                    amount: String(amount),
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

extension TransactionService {
    class ERC20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let bigNumber = try EthereumNetwork().getWeb3().eth.getGasPrice()
                self.gasPrice = (bigNumber.words.first ?? 1) * 4
            } catch {
                self.gasPrice = 4
            }
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            do {
                let txhash = try EthereumTxSender().sendToken(
                    to: toAddress,
                    amountString: "\(amount)",
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    erc20TokenAddress: token.address,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

class EthereumTxSender {
    // TODO: queue async
    func sendETH(
        to: String,
        amount: String,
        gasLimit: UInt = 21000,
        gasPrice: BigUInt,
        data: Data,
        password: String
    ) throws -> TxHash {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
        let keystore = WalletManager.default.keystore(for: wallet.address)

        guard let destinationEthAddress = EthereumAddress(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {
            throw SendTransactionError.invalidAmountFormat
        }

        let web3 = EthereumNetwork().getWeb3()
        web3.addKeystoreManager(KeystoreManager([keystore]))

        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
            throw SendTransactionError.contractLoadingError
        }

        var options = TransactionOptions()
        options.gasLimit = .limited(BigUInt(gasLimit))
        options.gasPrice = .manual(gasPrice)
        options.from = EthereumAddress(wallet.address)
        options.value = value

        guard let transaction = contract.method(transactionOptions: options) else {
            throw SendTransactionError.createTransactionIssue
        }

        let result = try transaction.sendPromise(password: password).wait()
        return result.hash
    }

    func sendToken(
        to: String,
        amountString: String,
        gasLimit: UInt = 21000,
        gasPrice: BigUInt,
        erc20TokenAddress: String,
        password: String
    ) throws -> TxHash {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
        let keystore = WalletManager.default.keystore(for: wallet.address)

        guard let destinationEthAddress = EthereumAddress(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        guard Web3.Utils.parseToBigUInt(amountString, units: .eth) != nil else {
            throw SendTransactionError.invalidAmountFormat
        }

        guard let tokenAddress = EthereumAddress(erc20TokenAddress), let fromAddress = EthereumAddress(wallet.address) else {
            throw SendTransactionError.createTransactionIssue
        }

        let web3 = EthereumNetwork().getWeb3()
        web3.addKeystoreManager(KeystoreManager([keystore]))

        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(gasLimit)
        options.gasPrice = gasPrice
        options.from = fromAddress
        // TODO: estimate gas

        do {
            guard let transaction = try web3.eth.sendERC20tokensWithNaturalUnits(
                tokenAddress: tokenAddress,
                from: fromAddress,
                to: destinationEthAddress,
                amount: amountString
            ) else {
                throw SendTransactionError.createTransactionIssue
            }

            let result = try transaction.sendPromise(password: password, transactionOptions: nil).wait()
            return result.hash
        } catch {
            throw SendTransactionError.createTransactionIssue
        }
    }
}
