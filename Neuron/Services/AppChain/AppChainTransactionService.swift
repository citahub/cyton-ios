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
    class Nervos: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
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
                let txhash = try AppChainTransactionService().send(
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
    class NervosErc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 100000
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

class AppChainTransactionService {
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
            throw SendNervosError.invalidDestinationAddress
        }
        guard let amount = Web3Utils.parseToBigUInt(value, units: .eth) else {
            throw SendNervosError.invalidAmountFormat
        }

        let nonce = UUID().uuidString
        let appChain = AppChainNetwork.appChain()
        guard case .success(let blockNumber) = appChain.rpc.blockNumber() else {
            throw SendNervosError.createTransactionIssue
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
        guard case .success(let result) = AppChainNetwork.appChain().rpc.sendRawTransaction(signedTx: signed) else {
            throw NervosSignError.signTXFailed
        }
        return result.hash.toHexString()
    }

    func sendToken(
        transaction: Transaction,
        password: String
    ) throws -> TxHash {
        let signed = try sign(transaction: transaction, password: password)
        guard case .success(let result) = AppChainNetwork.appChain().rpc.sendRawTransaction(signedTx: signed) else {
            throw NervosSignError.signTXFailed
        }
        return result.hash.toHexString()
    }

    func sign(transaction: Transaction, password: String) throws -> String {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        guard let wallet = walletModel.wallet else {
            throw NervosSignError.signTXFailed
        }
        let privateKey = try WalletManager.default.exportPrivateKey(wallet: wallet, password: password)
        guard let signed = try? Signer().sign(transaction: transaction, with: privateKey) else {
            throw NervosSignError.signTXFailed
        }
        return signed
    }
}
