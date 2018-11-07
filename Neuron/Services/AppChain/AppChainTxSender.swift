//
//  AppChainTransactionService.swift
//  Neuron
//
//  Created by James Chen on 2018/11/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

extension TransactionService {
    class AppChain: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21_000
            do {
                let result = try Utils.getQuotaPrice(appChain: AppChainNetwork.appChain()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }

        override func sendTransaction() {
            // TODO: queue async
            super.sendTransaction()
            do {
                // TODO: pass in wallet and selected AppChain
                let sender = AppChainTxSender(appChain: AppChainNetwork.appChain(), walletManager: WalletManager.default, from: fromAddress)
                let txhash = try sender.send(
                    to: toAddress,
                    quota: BigUInt(UInt(gasLimit/* * gasPrice*/)),
                    data: extraData,
                    value: "\(amount)",
                    tokenHosts: token.chainHosts,
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

extension TransactionService {
    class AppChainERC20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 100_000
            do {
                let result = try Utils.getQuotaPrice(appChain: AppChainNetwork.appChain()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }
    }
}

class AppChainTxSender {
    private let appChain: AppChain
    private let walletManager: WalletManager
    private let from: String

    init(appChain: AppChain, walletManager: WalletManager, from: String) {
        self.appChain = appChain
        self.walletManager = walletManager
        self.from = from
    }

    func send(
        to: String,
        quota: BigUInt = BigUInt(21_000),
        data: Data,
        value: String,
        tokenHosts: String = "",
        chainId: BigUInt,
        password: String
    ) throws -> TxHash {
        guard let destinationEthAddress = Address(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }
        guard let amount = Web3Utils.parseToBigUInt(value, units: .eth) else {
            throw SendTransactionError.invalidAmountFormat
        }

        let nonce = UUID().uuidString
        let appChain = AppChainNetwork.appChain()
        guard case .success(let blockNumber) = appChain.rpc.blockNumber() else {
            throw SendTransactionError.createTransactionIssue
        }
        let transaction = Transaction(
            to: destinationEthAddress,
            nonce: nonce,
            quota: UInt64(quota),
            validUntilBlock: blockNumber + UInt64(88),
            data: data,
            value: amount,
            chainId: UInt32(chainId),
            version: UInt32(0)
        )
        let signed = try sign(transaction: transaction, password: password)
        guard case .success(let result) = appChain.rpc.sendRawTransaction(signedTx: signed) else {
            throw SendTransactionError.signTXFailed
        }
        return result.hash.toHexString()
    }

    func sendToken(
        transaction: Transaction,
        password: String
    ) throws -> TxHash {
        let signed = try sign(transaction: transaction, password: password)
        guard case .success(let result) = appChain.rpc.sendRawTransaction(signedTx: signed) else {
            throw SendTransactionError.signTXFailed
        }
        return result.hash.toHexString()
    }

    func sign(transaction: Transaction, password: String) throws -> String {
        guard let wallet = walletManager.wallet(for: from) else {
            throw SendTransactionError.noAvailableKeys
        }
        let privateKey = try walletManager.exportPrivateKey(wallet: wallet, password: password)
        guard let signed = try? Signer().sign(transaction: transaction, with: privateKey) else {
            throw SendTransactionError.signTXFailed
        }
        return signed
    }
}
