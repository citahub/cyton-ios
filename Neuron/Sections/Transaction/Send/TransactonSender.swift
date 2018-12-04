//
//  TransactonSender.swift
//  Neuron
//
//  Created by 晨风 on 2018/12/4.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import AppChain
import Web3swift

protocol TransactonSender {
    var paramBuilder: TransactionParamBuilder! { get set }
    func sendEthereumTransaction(password: String) throws -> TxHash
    func sendAppChainTransaction(password: String) throws -> TxHash
}

extension TransactonSender {
    func sendEthereumTransaction(password: String) throws -> TxHash {
        let keystore = WalletManager.default.keystore(for: paramBuilder.from)
        let web3 = EthereumNetwork().getWeb3()
        web3.addKeystoreManager(KeystoreManager([keystore]))

        if paramBuilder.tokenType == .ether {
            let sender = try EthereumTxSender(web3: web3, from: paramBuilder.from)
            return try sender.sendETH(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                data: paramBuilder.data,
                password: password
            )
        } else {
            let sender = try EthereumTxSender(web3: web3, from: paramBuilder.from)
            return try sender.sendToken(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                contractAddress: paramBuilder.contractAddress,
                password: password
            )
        }
    }

    func sendAppChainTransaction(password: String) throws -> TxHash {
        let appChain: AppChain
        if paramBuilder.rpcNode.isEmpty {
            appChain = AppChainNetwork.appChain()
        } else {
            guard let appChainUrl = URL(string: paramBuilder.rpcNode) else {
                throw SendTransactionError.invalidAppChainNode
            }
            appChain = AppChainNetwork.appChain(url: appChainUrl)
        }
        if paramBuilder.tokenType == .appChain {
            let sender = try AppChainTxSender(
                appChain: appChain,
                walletManager: WalletManager.default,
                from: paramBuilder.from
            )
            return try sender.send(
                to: paramBuilder.to,
                value: paramBuilder.value,
                quota: paramBuilder.gasLimit,
                data: paramBuilder.data,
                chainId: BigUInt(paramBuilder.chainId)!,
                password: password
            )
        } else {
            return "" // TODO: AppChainErc20 not implemented yet.
        }
    }
}
