//
//  AppChainTxSender.swift
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
    private let from: Address

    init(appChain: AppChain, walletManager: WalletManager, from: String) throws {
        self.appChain = appChain
        self.walletManager = walletManager
        guard let fromAddress = Address(from) else {
            throw SendTransactionError.invalidSourceAddress
        }
        self.from = fromAddress
    }

    func send(
        to: String,
        value: BigUInt,
        quota: UInt64 = GasCalculator.defaultGasLimit,
        data: Data,
        chainId: BigUInt,
        password: String
    ) throws -> TxHash {
        guard let destinationEthAddress = Address(to) else {
            throw SendTransactionError.invalidDestinationAddress
        }

        let appChain = AppChainNetwork.appChain() // TODO: get rpc node for current AppChain
        guard let meta = try? appChain.rpc.getMetaData() else {
            throw SendTransactionError.createTransactionIssue
        }
        guard let blockNumber = try? appChain.rpc.blockNumber() else {
            throw SendTransactionError.createTransactionIssue
        }
        if chainId.description != meta.chainId {
            throw SendTransactionError.invalidChainId
        }

        let transaction = Transaction(
            to: destinationEthAddress,
            nonce: UUID().uuidString,
            quota: quota,
            validUntilBlock: blockNumber + UInt64(88),
            data: data,
            value: value,
            chainId: meta.chainId,
            version: meta.version
        )
        let signed = try sign(transaction: transaction, password: password)
        let txHash = try appChain.rpc.sendRawTransaction(signedTx: signed)
        let sentTransaction = SentTransaction(tokenType: .appChain, from: from.address, hash: txHash, transaction: transaction)
        TransactionStatusManager.manager.insertTransaction(transaction: sentTransaction)
        return txHash
    }

    func sendToken(transaction: Transaction, password: String) throws -> TxHash {
        let signed = try sign(transaction: transaction, password: password)
        return try appChain.rpc.sendRawTransaction(signedTx: signed)
    }

    func sign(transaction: Transaction, password: String) throws -> String {
        guard let wallet = walletManager.wallet(for: from.address) else {
            throw SendTransactionError.noAvailableKeys
        }
        let privateKey = try walletManager.exportPrivateKey(wallet: wallet, password: password)
        guard let signed = try? Signer().sign(transaction: transaction, with: privateKey) else {
            throw SendTransactionError.signTXFailed
        }
        return signed
    }
}
