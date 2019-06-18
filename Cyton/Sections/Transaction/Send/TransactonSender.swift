//
//  TransactonSender.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/4.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import CITA
import web3swift

protocol TransactonSender {
    var token: Token! { get set }
    var paramBuilder: TransactionParamBuilder! { get set }
    func sendEthereumTransaction(password: String) throws -> TxHash
    func sendCITATransaction(password: String) throws -> TxHash
}

extension TransactonSender {
    func sendEthereumTransaction(password: String) throws -> TxHash {
        let keystore = WalletManager.default.keystore(for: paramBuilder.from)
        let web3 = EthereumNetwork().getWeb3()
        web3.addKeystoreManager(KeystoreManager([keystore]))

        if paramBuilder.tokenType == .ether {
            let sender = try EthereumTxSender(web3: web3, from: paramBuilder.from)
            let txhash = try sender.sendETH(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                data: paramBuilder.data,
                password: password
            )
            recordEthereumTx(txhash: txhash)
            return txhash
        } else {
            let sender = try EthereumTxSender(web3: web3, from: paramBuilder.from)
            let txhash = try sender.sendToken(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                contractAddress: paramBuilder.contractAddress,
                password: password
            )
            recordEthereumTx(txhash: txhash)
            return txhash
        }
    }

    func sendCITATransaction(password: String) throws -> TxHash {
        let cita: CITA
        if paramBuilder.rpcNode.isEmpty {
            cita = CITANetwork().cita
        } else {
            guard let citaUrl = URL(string: paramBuilder.rpcNode) else {
                throw SendTransactionError.invalidCITANode
            }
            cita = CITANetwork(url: citaUrl).cita
        }
        let sender = try CITATxSender(
            cita: cita,
            walletManager: WalletManager.default,
            from: paramBuilder.from
        )
        if paramBuilder.tokenType == .cita {
            let result = try sender.send(
                to: paramBuilder.to,
                value: paramBuilder.value,
                quota: paramBuilder.gasLimit,
                data: paramBuilder.data,
                chainId: paramBuilder.chainId,
                password: password
            )
            recordCITATx(txhash: result.0, validUntilBlock: result.1)
            return result.0
        } else {
            let result = try sender.sendERC20(
                to: paramBuilder.to,
                contract: paramBuilder.contractAddress,
                value: paramBuilder.value,
                quota: paramBuilder.gasLimit,
                chainId: BigUInt(paramBuilder.chainId)!,
                password: password)
            recordCITATx(txhash: result.0, validUntilBlock: result.1)
            return result.0
        }
    }

    func recordEthereumTx(txhash: String) {
        EthereumLocalTxPool.pool.insertLocalTx(localTx: EthereumLocalTx(
            token: token.tokenModel, txHash: txhash,
            from: paramBuilder.from, to: paramBuilder.to, value: paramBuilder.value,
            gasPrice: paramBuilder.gasPrice, gasLimit: paramBuilder.gasLimit
        ))
    }

    func recordCITATx(txhash: String, validUntilBlock: BigUInt) {
        CITALocalTxPool.pool.insertLocalTx(localTx: CITALocalTx(
            token: token.tokenModel, txHash: txhash, validUntilBlock: validUntilBlock,
            from: paramBuilder.from, to: paramBuilder.to, value: paramBuilder.value,
            quotaPrice: paramBuilder.gasPrice, quotaLimit: paramBuilder.gasLimit
        ))
    }
}
