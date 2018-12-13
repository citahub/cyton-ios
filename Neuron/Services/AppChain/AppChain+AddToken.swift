//
//  AppChain+AddToken.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class AddAppChainToken {
    static func appChainNativeToken(nodeAddress: String) -> (TokenModel?, ChainModel?) {
        if !nodeAddress.hasPrefix("http") {
            return (nil, nil)
        }
        let appChain = AppChainNetwork.appChain(url: URL(string: nodeAddress))
        guard let metaData = try? appChain.rpc.getMetaData() else {
            return (nil, nil)
        }
        let chainModel = ChainModel()
        chainModel.chainId = metaData.chainId
        chainModel.chainName = metaData.chainName
        chainModel.httpProvider = nodeAddress
        if let chainIndentifier = ChainModel.identifier(for: chainModel) {
            chainModel.identifier = chainIndentifier
        }

        let tokenModel = TokenModel()
        tokenModel.address = ""
        tokenModel.iconUrl = metaData.tokenAvatar
        tokenModel.isNativeToken = true
        tokenModel.name = metaData.tokenName
        tokenModel.symbol = metaData.tokenSymbol
        tokenModel.decimals = NativeDecimals.nativeTokenDecimals
        tokenModel.chain = chainModel
        if let id = TokenModel.identifier(for: tokenModel) {
            tokenModel.identifier = id
        }
        return (tokenModel, chainModel)
    }

    static func appChainERC20Token(chain: Chain, contractAddress: String) -> TokenModel? {
        do {
            let appChain = AppChainNetwork.appChain(url: URL(string: chain.httpProvider))
            let appchainErc20 = AppChainERC20(appChain: appChain, contractAddress: contractAddress)

            guard let name = try appchainErc20.name() else {
                return nil
            }

            guard let symbol = try appchainErc20.symbol() else {
                return nil
            }

            guard let decimals = try appchainErc20.decimals() else {
                return nil
            }

            let realm = try! Realm()
            let result = realm.objects(ChainModel.self)
            let chainModel = result.first(where: { $0.chainId == chain.chainId && $0.chainName == chain.chainName && $0.httpProvider == chain.httpProvider })

            let tokenModel = TokenModel()
            tokenModel.decimals = Int(decimals)
            tokenModel.name = name
            tokenModel.symbol = symbol
            tokenModel.address = contractAddress
            tokenModel.isNativeToken = false
            tokenModel.chain = chainModel
            return tokenModel
        } catch {
            return nil
        }
    }
}
