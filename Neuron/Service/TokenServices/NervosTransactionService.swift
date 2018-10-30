//
//  NervosTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/22.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation
import web3swift
import AppChain
import struct AppChain.TransactionSendingResult
import struct BigInt.BigUInt

class NervosTransactionService {
    func prepareNervosTransactionForSending(address: String,
                                            quota: BigUInt = BigUInt(1000000),
                                            data: Data,
                                            value: String,
                                            tokenHosts: String = "",
                                            chainId: BigUInt, completion: @escaping (SendNervosResult<Transaction>) -> Void) {
        DispatchQueue.global().async {
            guard let destinationEthAddress = Address(address) else {
                DispatchQueue.main.async {
                    completion(SendNervosResult.error(SendNervosError.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Web3Utils.parseToBigUInt(value, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendNervosResult.error(SendNervosError.invalidAmountFormat))
                }
                return
            }
            let nonce = UUID().uuidString
            let appChain = NervosNetwork.getNervos()
            let result = appChain.rpc.blockNumber()
            DispatchQueue.main.async {
                switch result {
                case .success(let blockNumber):
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
                    completion(SendNervosResult.success(transaction))
                case .failure(let error):
                    completion(SendNervosResult.error(error))
                }
            }
        }
    }

    func send(password: String, transaction: Transaction, completion: @escaping (SendNervosResult<TransactionSendingResult>) -> Void) {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        guard let account = WalletTool.account(for: walletModel.address) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        guard case .succeed(result: let privateKey) = WalletTool.exportPrivateKey(account: account, password: password) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        guard let signed = try? Signer().sign(transaction: transaction, with: privateKey) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        DispatchQueue.global().async {
            let result = NervosNetwork.getNervos().rpc.sendRawTransaction(signedTx: signed)
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    completion(SendNervosResult.success(transaction))
                case .failure(let error):
                    completion(SendNervosResult.error(error))
                }
            }
        }
    }

    func sign(password: String, transaction: Transaction, completion: @escaping (SendNervosResult<String>) -> Void) {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        guard let account = WalletTool.account(for: walletModel.address) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        guard case .succeed(result: let privateKey) = WalletTool.exportPrivateKey(account: account, password: password) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        guard let signed = try? Signer().sign(transaction: transaction, with: privateKey) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        completion(SendNervosResult.success(signed))
    }
}
