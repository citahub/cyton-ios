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
                                      chainId: BigUInt, completion: @escaping (SendEthResult<NervosTransaction>) -> Void)

    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void)
}

class NervosTransactionServiceImp: NervosTransactionServiceProtocol {

    func prepareTransactionForSending(address: String,
                                      nonce: String = "",
                                      quota: BigUInt = BigUInt(100000),
                                      data: Data,
                                      value: String,
                                      chainId: BigUInt, completion: @escaping (SendEthResult<NervosTransaction>) -> Void) {
        DispatchQueue.global().async {
            guard let destinationEthAddress = Address(address) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Utils.parseToBigUInt(value, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                }
                return
            }
//            let finalValue = Data(hex: String(amount,radix: 16))
            guard let nonceBInt = randomNumberString() else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.noAvailableKeys))
                }
                return
            }
            let ner = NervosNetwork.getNervos()
            let bnResult = ner.appChain.blockNumber()
            DispatchQueue.main.async {
                switch bnResult {
                case .success(let blockNum):
                    print(amount.description)
                    print(amount.description.data(using: String.Encoding.utf8)!)
                    print(UInt64(quota).description)
                    let transaction = NervosTransaction.init(to: destinationEthAddress, nonce: nonceBInt, data: data, value: amount, validUntilBlock: blockNum + BigUInt(88), quota: quota, version: BigUInt(0), chainId: chainId)
                    completion(SendEthResult.Success(transaction))
                case .failure(let error):
                    completion(SendEthResult.Error(error))
                }
            }
        }
    }
    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        let ner = NervosNetwork.getNervos()
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        var walletPrivate = CryptTools.Decode_AES_ECB(strToDecode: walletModel.encryptPrivateKey, key: password)
        print(walletPrivate)
        if walletPrivate.hasPrefix("0x") {
            walletPrivate = String(walletPrivate.dropFirst(2))
        }
        guard let signed = try? NervosTransactionSigner.sign(transaction: transaction, with: walletPrivate) else {
            completion(SendEthResult.Error(NervosSignErrors.signTXFailed))
            return
        }
        DispatchQueue.global().async {
            let result = ner.appChain.sendRawTransaction(signedTx: signed)
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    completion(SendEthResult.Success(transaction))
                case .failure(let error):
                    completion(SendEthResult.Error(error))
                }
            }
        }
    }
}
