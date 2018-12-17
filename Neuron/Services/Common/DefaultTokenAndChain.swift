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
        let walletRef = ThreadSafeReference(to: wallet)
        DispatchQueue.global().async {
            let realm = try! Realm()
            guard let walletModel = realm.resolve(walletRef) else {
                return
            }
            self.ethereum(wallet: walletModel)
            self.testChain(wallet: walletModel)
        }
    }

    func ethereum(wallet: WalletModel) {
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
        try? realm.write {
            realm.add(ethModel, update: true)
            if !wallet.tokenModelList.contains(where: { $0 == ethModel }) {
                wallet.tokenModelList.append(ethModel)
            }
            if !wallet.selectedTokenList.contains(where: { $0 == ethModel }) {
                wallet.selectedTokenList.append(ethModel)
            }
        }
    }

    func testChain(wallet: WalletModel) {
        do {
            let metaData = try AppChainNetwork.appChain().rpc.getMetaData()
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
            chainModel.httpProvider = AppChainNetwork.defaultNode
            chainModel.tokenIdentifier = tokenModel.identifier
            if let chainIdentifier = ChainModel.identifier(for: chainModel) {
                chainModel.identifier = chainIdentifier
            }
            tokenModel.chainIdentifier = chainModel.identifier

            let realm = try Realm()
            try realm.write {
                realm.add(tokenModel, update: true)
                realm.add(chainModel, update: true)
                if !wallet.selectedTokenList.contains(where: { $0 == tokenModel }) {
                    wallet.selectedTokenList.append(tokenModel)
                }
                if !wallet.tokenModelList.contains(where: { $0 == tokenModel }) {
                    wallet.tokenModelList.append(tokenModel)
                }
                if !wallet.chainModelList.contains(where: { $0 == chainModel }) {
                    wallet.chainModelList.append(chainModel)
                }
            }
        } catch {
        }

    }

}
