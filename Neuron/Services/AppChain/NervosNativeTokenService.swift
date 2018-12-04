//
//  NervosNativeTokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

struct NervosNativeTokenService {
    static func getNervosNativeTokenMsg(blockNumber: String = "latest") throws -> TokenModel {
        let appChain = AppChainNetwork.appChain()
        let metaData = try appChain.rpc.getMetaData(blockNumber: blockNumber)
        let tokenModel = TokenModel()
        tokenModel.address = ""
        tokenModel.chainId = metaData.chainId.description
        tokenModel.chainName = metaData.chainName
        tokenModel.iconUrl = metaData.tokenAvatar
        tokenModel.isNativeToken = true
        tokenModel.name = metaData.tokenName
        tokenModel.symbol = metaData.tokenSymbol
        tokenModel.decimals = NativeDecimals.nativeTokenDecimals
        return tokenModel
    }
}
