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
    var token: Token! { get set }
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
            let txhash = try sender.sendETH(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                data: paramBuilder.data,
                password: password
            )
            recordTxDetails(txhash: txhash)
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
            recordTxDetails(txhash: txhash)
            return txhash
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
        let sender = try AppChainTxSender(
            appChain: appChain,
            walletManager: WalletManager.default,
            from: paramBuilder.from
        )
        if paramBuilder.tokenType == .appChain {
            let result = try sender.send(
                to: paramBuilder.to,
                value: paramBuilder.value,
                quota: paramBuilder.gasLimit,
                data: paramBuilder.data,
                chainId: BigUInt(paramBuilder.chainId)!,
                password: password
            )
            recordTxDetails(txhash: result.0, blockNumber: result.1)
            return result.0
        } else {
            let result = try sender.sendERC20(
                to: paramBuilder.to,
                contract: paramBuilder.contractAddress,
                value: paramBuilder.value,
                quota: paramBuilder.gasLimit,
                chainId: BigUInt(paramBuilder.chainId)!,
                password: password)
            recordTxDetails(txhash: result.0, blockNumber: result.1)
            return result.0
        }
    }

    func recordTxDetails(txhash: String, blockNumber: BigUInt? = nil) {
        let cetateModelBlock = { () -> LocalTxDetailModel in
            switch self.paramBuilder.tokenType {
            case .ether:
                return LocalTxDetailModel(
                    tokenIdentifier: self.paramBuilder.tokenIdentifier,
                    txHash: txhash,
                    from: self.paramBuilder.from, to: self.paramBuilder.to,
                    value: self.paramBuilder.value,
                    gasPrice: self.paramBuilder.gasPrice,
                    gasLimit: self.paramBuilder.gasLimit
                )
            case .erc20:
                return LocalTxDetailModel(
                    contractAddress: self.paramBuilder.contractAddress,
                    tokenIdentifier: self.paramBuilder.tokenIdentifier,
                    txHash: txhash,
                    from: self.paramBuilder.from, to: self.paramBuilder.to,
                    value: self.paramBuilder.value,
                    gasPrice: self.paramBuilder.gasPrice,
                    gasLimit: self.paramBuilder.gasLimit
                )
            case .appChain:
                return LocalTxDetailModel(
                    tokenIdentifier: self.paramBuilder.tokenIdentifier,
                    txHash: txhash,
                    from: self.paramBuilder.from, to: self.paramBuilder.to,
                    value: self.paramBuilder.value,
                    gasPrice: self.paramBuilder.gasPrice,
                    gasLimit: self.paramBuilder.gasLimit,
                    blockNumber: blockNumber!
                )
            case .appChainErc20:
                return LocalTxDetailModel(
                    contractAddress: self.paramBuilder.contractAddress,
                    tokenIdentifier: self.paramBuilder.tokenIdentifier,
                    txHash: txhash,
                    from: self.paramBuilder.from, to: self.paramBuilder.to,
                    value: self.paramBuilder.value,
                    gasPrice: self.paramBuilder.gasPrice,
                    gasLimit: self.paramBuilder.gasLimit,
                    blockNumber: blockNumber!
                )
            }
        }
        TxStatusManager.manager.insertLocalTxDetail(cetateModelBlock: cetateModelBlock)
    }
}
