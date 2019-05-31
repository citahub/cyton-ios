//
//  EthereumTxSender.swift
//  Cyton
//
//  Created by James Chen on 2018/11/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import web3swift

class EthereumTxSender {
    private let web3: web3
    private let from: EthereumAddress

    init(web3: web3, from: String) throws {
        self.web3 = web3
        guard let fromAddress = EthereumAddress(from) else {
            throw SendTransactionError.invalidSourceAddress
        }
        self.from = fromAddress
    }

    /// All parameters should be final, e.g., value should be 10**18 for 1.0 Ether, gasPrice should be 10**9 for 1Gwei.
    func sendETH(
        to: String,
        value: BigUInt,
        gasLimit: BigUInt = GasCalculator.defaultGasLimit,
        gasPrice: BigUInt,
        data: Data,
        password: String
    ) throws -> TxHash {
        guard let toAddress = EthereumAddress(to.addHexPrefix()) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        var options = TransactionOptions()
        options.gasLimit = .manual(BigUInt(gasLimit))
        options.gasPrice = .manual(gasPrice)
        options.from = from

        guard let transaction = web3.eth.sendETH(
            to: toAddress,
            amount: value,
            extraData: data,
            transactionOptions: options
        ) else {
            throw SendTransactionError.createTransactionIssue
        }

        transaction.transaction.value = value  // Web3swift seems to be having bug setting value
        return try transaction.sendPromise(password: password).wait().hash
    }

    func sendToken(
        to: String,
        value: BigUInt,
        gasLimit: BigUInt = GasCalculator.defaultGasLimit,
        gasPrice: BigUInt,
        contractAddress: String,
        password: String
    ) throws -> TxHash {
        guard let destinationAddress = EthereumAddress(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        guard let tokenAddress = EthereumAddress(contractAddress) else {
            throw SendTransactionError.invalidContractAddress
        }

        guard let transaction = web3.eth.sendERC20tokensWithKnownDecimals(
            tokenAddress: tokenAddress,
            from: from,
            to: destinationAddress,
            amount: value
        ) else {
            throw SendTransactionError.createTransactionIssue
        }

        transaction.transactionOptions.gasLimit = .manual(BigUInt(gasLimit))
        transaction.transactionOptions.gasPrice = .manual(gasPrice)
        return try transaction.sendPromise(password: password).wait().hash
    }
}
