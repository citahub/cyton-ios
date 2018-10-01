//
//  NervosNativeTokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Nervos
import BigInt

class NervosNativeTokenService {
    static func getNervosNativeTokenMsg(blockNumber: String = "latest", completion: @escaping (NervosServiceResult<TokenModel>) -> Void) {
        let nervos = NervosNetwork.getNervos()
        DispatchQueue.global().async {
            let result = nervos.appChain.getMetaData(blockNumber: blockNumber)
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
                    tokenModel.decimals = NaticeDecimals.nativeTokenDecimals
                    tokenModel.chainidName = metaData.chainName + metaData.chainId.description
                    completion(NervosServiceResult.Success(tokenModel))
                case .failure(let error):
                    completion(NervosServiceResult.Error(error))
                }
            }
        }
    }

    static func getNervosNativeTokenBalance(walletAddress: String, completion: @escaping (NervosServiceResult<BigUInt>) -> Void) {
        let nervos = NervosNetwork.getNervos()
        DispatchQueue.global().async {
            let result = nervos.appChain.getBalance(address: Address(walletAddress)!)
            DispatchQueue.main.async {
                switch result {
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
