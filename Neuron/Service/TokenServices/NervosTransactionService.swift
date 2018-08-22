//
//  NervosTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/22.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation
import Nervos
import BigInt
//import web3swift

protocol NervosTransactionServiceProtocol {
    func prepareTransactionForSending(address: String,
                                      nonce: String,
                                      quota: BigUInt,
                                      data: Data,
                                      value: String,
                                      chainId: BigUInt, completion: @escaping (SendNervosResult<NervosTransaction>) -> Void)

    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendNervosResult<TransactionSendingResult>) -> Void)
}

class NervosTransactionServiceImp: NervosTransactionServiceProtocol {

    func prepareTransactionForSending(address: String,
                                      nonce: String = "",
                                      quota: BigUInt = BigUInt(100000),
                                      data: Data,
                                      value: String,
                                      chainId: BigUInt, completion: @escaping (SendNervosResult<NervosTransaction>) -> Void) {
        DispatchQueue.global().async {
            guard let destinationEthAddress = Address(address) else {
                DispatchQueue.main.async {
                    completion(SendNervosResult.Error(SendNervosErrors.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Utils.parseToBigUInt(value, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendNervosResult.Error(SendNervosErrors.invalidAmountFormat))
                }
                return
            }
//            let finalValue = Data(hex: String(amount,radix: 16))
            guard let nonceBInt = randomNumberString() else {
                DispatchQueue.main.async {
                    completion(SendNervosResult.Error(SendNervosErrors.emptyNonce))
                }
                return
            }
            let ner = NervosNetwork.getNervos()
            let bnResult = ner.appChain.blockNumber()
            DispatchQueue.main.async {
                switch bnResult {
                case .success(let blockNum):
                    let transaction = NervosTransaction.init(to: destinationEthAddress, nonce: nonceBInt, data: data, value: amount, validUntilBlock: blockNum + BigUInt(88), quota: quota, version: BigUInt(0), chainId: chainId)
                    completion(SendNervosResult.Success(transaction))
                case .failure(let error):
                    completion(SendNervosResult.Error(error))
                }
            }
        }
    }
    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendNervosResult<TransactionSendingResult>) -> Void) {
        let ner = NervosNetwork.getNervos()
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        var walletPrivate = CryptTools.Decode_AES_ECB(strToDecode: walletModel.encryptPrivateKey, key: password)
        print(walletPrivate)
        if walletPrivate.hasPrefix("0x") {
            walletPrivate = String(walletPrivate.dropFirst(2))
        }
        guard let signed = try? NervosTransactionSigner.sign(transaction: transaction, with: walletPrivate) else {
            completion(SendNervosResult.Error(NervosSignErrors.signTXFailed))
            return
        }
        DispatchQueue.global().async {
            let result = ner.appChain.sendRawTransaction(signedTx: signed)
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    completion(SendNervosResult.Success(transaction))
                case .failure(let error):
                    completion(SendNervosResult.Error(error))
                }
            }
        }
    }
}
