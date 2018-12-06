//
//  DefaultTokenAndChain.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/6.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class DefaultTokenAndChain {
    func addDefaultTokenToWallet(wallet: WalletModel) {
        ethereum(wallet: wallet)
        mba(wallet: wallet)
    }

    func ethereum(wallet: WalletModel) {
        let walletRef = ThreadSafeReference(to: wallet)
        let ethModel = TokenModel()
        ethModel.address = ""
        ethModel.decimals = NativeDecimals.nativeTokenDecimals
        ethModel.iconUrl = ""
        ethModel.isNativeToken = true
        ethModel.name = "ethereum"
        ethModel.symbol = "ETH"
        if let id = TokenModel.identifier(for: ethModel) {
            ethModel.identifier = id
        }

        let realm = try! Realm()
        guard let walletModel = realm.resolve(walletRef) else {
            return
        }
        try? realm.write {
            realm.add(ethModel, update: true)
            if !walletModel.tokenModelList.contains(where: { $0 == ethModel }) {
                walletModel.tokenModelList.append(ethModel)
            }
            if !walletModel.selectedTokenList.contains(where: { $0 == ethModel }) {
                walletModel.selectedTokenList.append(ethModel)
            }
        }
    }

    func mba(wallet: WalletModel) {
        let walletRef = ThreadSafeReference(to: wallet)
        DispatchQueue.global().async {
            let mbaHost = "http://testnet.mba.cmbchina.biz:1337"
            do {
                let metaData = try AppChainNetwork.appChain(url: URL(string: mbaHost)!).rpc.getMetaData()
                let tokenModel = TokenModel()
                tokenModel.symbol = metaData.tokenSymbol
                tokenModel.iconUrl = metaData.tokenAvatar
                tokenModel.name = metaData.tokenName
                tokenModel.isNativeToken = true
                if let tokenIdentifier = TokenModel.identifier(for: tokenModel) {
                    tokenModel.identifier = tokenIdentifier
                }

                let chainModel = ChainModel()
                chainModel.chainId = metaData.chainId
                chainModel.chainName = metaData.chainName
                chainModel.httpProvider = mbaHost
                chainModel.tokenIdentifier = tokenModel.identifier
                if let chainIdentifier = ChainModel.identifier(for: chainModel) {
                    chainModel.identifier = chainIdentifier
                }
                tokenModel.chain = chainModel

                let realm = try Realm()
                guard let walletModel = realm.resolve(walletRef) else {
                    return
                }
                try realm.write {
                    realm.add(tokenModel, update: true)
                    realm.add(chainModel, update: true)
                    if !walletModel.selectedTokenList.contains(where: { $0 == tokenModel }) {
                        walletModel.selectedTokenList.append(tokenModel)
                    }
                    if !walletModel.tokenModelList.contains(where: { $0 == tokenModel }) {
                        walletModel.tokenModelList.append(tokenModel)
                    }
                    if !walletModel.chainModelList.contains(where: { $0 == chainModel }) {
                        walletModel.chainModelList.append(chainModel)
                    }
                }
            } catch {
            }
        }

    }

}
