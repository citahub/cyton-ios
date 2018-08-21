//
//  NervosTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import NervosSwift
import BigInt

protocol NervosTransactionServiceProtocol {
    func prepareTransactionForSending(address:String,
    nonce:String,
    quota:BigUInt,
    data:Data,
    value:String,
    chainId:BigUInt,completion: @escaping (SendEthResult<NervosTransaction>) -> Void)
    
    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendEthResult<NervosTransactionSendingResult>) -> Void)
}

class NervosTransactionServiceImp: NervosTransactionServiceProtocol {
    
    func prepareTransactionForSending(address:String,
                                      nonce:String = "",
                                      quota:BigUInt = BigUInt(100000),
                                      data:Data,
                                      value:String,
                                      chainId:BigUInt,completion: @escaping (SendEthResult<NervosTransaction>) -> Void){
        DispatchQueue.global().async {
            
            guard let destinationEthAddress = EthereumAddress(address) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidDestinationAddress))
                }
                return
            }
            
            guard let amount = Nervos.Utils.parseToBigUInt(value, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                }
                return
            }
            let finalValue = Data(hex: String(amount,radix: 16))
            
            guard let nonceBInt = BigUInt(randomNumberString()) else{
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.noAvailableKeys))
                }
                return
            }
            
            let ner = NervosNetWork.getNervos()
            let bnResult = ner.appchain.getBlockNumber()
            DispatchQueue.main.async {
                switch bnResult{
                case .success(let blockNum):
                    print(amount.description)
                    print(amount.description.data(using: String.Encoding.utf8)!)
                    print(UInt64(quota).description)
                    let transaction = NervosTransaction.init(to: destinationEthAddress, nonce: nonceBInt, quota: quota, valid_until_block: blockNum + BigUInt(88), version: BigUInt(0), data: data, value:finalValue, chain_id: chainId)
                    completion(SendEthResult.Success(transaction))
                case .failure(let error):
                    completion(SendEthResult.Error(error))
                }
            }
        }
    }
    
    func send(password: String, transaction: NervosTransaction, completion: @escaping (SendEthResult<NervosTransactionSendingResult>) -> Void) {
        let ner = NervosNetWork.getNervos()
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        var walletPrivate = CryptTools.Decode_AES_ECB(strToDecode: walletModel.encryptPrivateKey, key: password)
        print(walletPrivate)
        if walletPrivate.hasPrefix("0x") {
            walletPrivate = String(walletPrivate.dropFirst(2))
        }
        print(walletPrivate)
        DispatchQueue.global().async {
            let result = ner.appchain.sendRawTransaction(transaction, privateKey: walletPrivate)
                DispatchQueue.main.async {
                    switch result{
                    case .success(let transaction):
                        completion(SendEthResult.Success(transaction))
                    case .failure(let error):
                        completion(SendEthResult.Error(error))
                    }
                }
            }
    }
}

