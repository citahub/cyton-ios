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
        guard let blockNumber = try? appChain.rpc.blockNumber() else {
            throw SendTransactionError.createTransactionIssue
        }
        let transaction = Transaction(
            to: destinationEthAddress,
            nonce: nonce,
            quota: UInt64(quota),
            validUntilBlock: blockNumber + UInt64(88),
            data: data,
            value: amount,
            chainId: chainId.description,
            version: UInt32(0)
        )
        let signed = try sign(transaction: transaction, password: password)
        do {
            return try appChain.rpc.sendRawTransaction(signedTx: signed)
        } catch {
            throw SendTransactionError.signTXFailed
        }
    }

    func sendToken(transaction: Transaction, password: String) throws -> TxHash {
        let signed = try sign(transaction: transaction, password: password)
        do {
            return try appChain.rpc.sendRawTransaction(signedTx: signed)
        } catch {
            throw SendTransactionError.signTXFailed
        }
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
