//
//  CITA+AddToken.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class AddCITAToken {
    static func nativeToken(nodeAddress: String) -> (TokenModel?, ChainModel?) {
        if !nodeAddress.hasPrefix("http") {
            return (nil, nil)
        }
        let cita = CITANetwork(url: URL(string: nodeAddress)).cita
        guard let metaData = try? cita.rpc.getMetaData() else {
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
        tokenModel.chainIdentifier = chainModel.identifier
        if let id = TokenModel.identifier(for: tokenModel) {
            tokenModel.identifier = id
        }
        return (tokenModel, chainModel)
    }

    static func erc20Token(chain: Chain, contractAddress: String) -> TokenModel? {
        do {
            let cita = CITANetwork(url: URL(string: chain.httpProvider)).cita
            let erc20 = CITAERC20(cita: cita, contractAddress: contractAddress)

            guard let name = try erc20.name() else {
                return nil
            }

            guard let symbol = try erc20.symbol() else {
                return TokenModel()
            }

            guard let decimals = try erc20.decimals() else {
                return nil
            }

            let realm = try! Realm()
            let result = realm.objects(ChainModel.self)
            let chainModel = result.first(where: { $0.chainId == chain.chainId && $0.chainName == chain.chainName })

            let tokenModel = TokenModel()
            tokenModel.decimals = Int(decimals)
            tokenModel.name = name
            tokenModel.symbol = symbol
            tokenModel.address = contractAddress
            tokenModel.isNativeToken = false
            tokenModel.chainIdentifier = chainModel!.identifier
            return tokenModel
        } catch {
            return nil
        }
    }
}
