//
//  NervosTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/22.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

class NervosTransactionService {
    func prepareNervosTransactionForSending(address: String,
                                            quota: BigUInt = BigUInt(1000000),
                                            data: Data,
                                            value: String,
                                            chainId: BigUInt, completion: @escaping (SendNervosResult<NervosTransaction>) -> Void) {
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
            let nervos = NervosNetwork.getNervos()
            let result = nervos.appChain.blockNumber()
            DispatchQueue.main.async {
                switch result {
                case .success(let blockNumber):
                    let transaction = NervosTransaction(
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

    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendNervosResult<TransactionSendingResult>) -> Void) {
        let nervos = NervosNetwork.getNervos()
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        guard let wallet = WalletTool.wallet(for: walletModel.address) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        guard case .succeed(result: let privateKey) = WalletTool.exportPrivateKey(wallet: wallet, password: password) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        guard let signed = try? NervosTransactionSigner.sign(transaction: transaction, with: privateKey) else {
            completion(SendNervosResult.error(NervosSignError.signTXFailed))
            return
        }
        DispatchQueue.global().async {
            let result = nervos.appChain.sendRawTransaction(signedTx: signed)
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
}
