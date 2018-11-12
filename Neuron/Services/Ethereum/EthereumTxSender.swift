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

class EthereumTxSender {
    private let web3: web3
    private let from: String

    init(web3: web3, from: String) {
        self.web3 = web3
        self.from = from
    }

    func sendETH(
        to: String,
        amount: String,
        gasLimit: UInt = 21000,
        gasPrice: BigUInt,
        data: Data,
        password: String
    ) throws -> TxHash {
        guard let toAddress = EthereumAddress(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {
            throw SendTransactionError.invalidAmountFormat
        }

        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2) else {
            throw SendTransactionError.contractLoadingError
        }

        guard let transaction = contract.write("fallback") else {
            throw SendTransactionError.createTransactionIssue
        }
        transaction.transactionOptions.gasLimit = .manual(BigUInt(gasLimit))
        transaction.transactionOptions.gasPrice = .manual(gasPrice)
        transaction.transactionOptions.from = EthereumAddress(from)
        transaction.transaction.value = value

        let result = try transaction.sendPromise(password: password).wait()
        return result.hash
    }

    func sendToken(
        to: String,
        amount: String,
        gasLimit: UInt = 21000,
        gasPrice: BigUInt,
        contractAddress: String,
        password: String
    ) throws -> TxHash {
        guard let destinationEthAddress = EthereumAddress(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        guard Web3.Utils.parseToBigUInt(amount, units: .eth) != nil else {
            throw SendTransactionError.invalidAmountFormat
        }

        guard let tokenAddress = EthereumAddress(contractAddress), let fromAddress = EthereumAddress(from) else {
            throw SendTransactionError.createTransactionIssue
        }

        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(gasLimit)
        options.gasPrice = gasPrice
        options.from = fromAddress

        do {
            // TODO: replace this with `sendERC20tokensWithKnownDecimals`.
            guard let transaction = try web3.eth.sendERC20tokensWithNaturalUnits(
                tokenAddress: tokenAddress,
                from: fromAddress,
                to: destinationEthAddress,
                amount: amount
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
