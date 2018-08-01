//
//  NervosNativeTokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import NervosSwift
import BigInt

protocol NervosNativeTokenServicePortocol {
    static func getNervosNativeTokenMsg(blockNumber:String,completion:@escaping (NervosServiceResult<TokenModel>) -> Void)
    static func getNervosNativeTokenBalance(walletAddress:String,completion:@escaping(NervosServiceResult<BigUInt>)->Void)
}

class NervosNativeTokenServiceImp: NervosNativeTokenServicePortocol {
    
    static func getNervosNativeTokenMsg(blockNumber:String = "latest",completion: @escaping (NervosServiceResult<TokenModel>) -> Void) {
        let nervos = NervosNetWork.getNervos()
        DispatchQueue.global().async {
            let result = nervos.appchain.getMetaData(blockNumber)
            DispatchQueue.main.async {
                switch result {
                case .success(let metaData):
                    let tokenModel = TokenModel()
                    tokenModel.address = ""
                    tokenModel.chainId = metaData.chainId.description
                    tokenModel.chainName = metaData.chainName
                    tokenModel.iconUrl = metaData.tokenAvatar
                    tokenModel.isNativeToken = true
                    tokenModel.name = metaData.tokenName
                    tokenModel.symbol = metaData.tokenSymbol
                    tokenModel.decimals = nativeTokenDecimals
                    tokenModel.chainidName = metaData.chainName + metaData.chainId.description
                    completion(NervosServiceResult.Success(tokenModel))
                    break
                case .failure(let error):
                    completion(NervosServiceResult.Error(error))
                    break
                }
            }
        }
    }
    
    static func getNervosNativeTokenBalance(walletAddress: String, completion: @escaping (NervosServiceResult<BigUInt>) -> Void) {
        let nervos = NervosNetWork.getNervos()
        DispatchQueue.global().async {
            let result = nervos.appchain.getBalance(address: EthereumAddress(walletAddress)!)
            DispatchQueue.main.async {
                switch result{
                case .success(let balance):
                    print(balance.description)
                    completion(NervosServiceResult.Success(balance))
                case .failure(let error):
                    completion(NervosServiceResult.Error(error))
                }
            }
        }
    }
}
