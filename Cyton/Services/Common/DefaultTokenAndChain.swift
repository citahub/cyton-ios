//
//  DefaultTokenAndChain.swift
//  Cyton
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
            self.testChain(chainHost: CITANetwork.defaultNode, wallet: walletModel)
            self.testChain(chainHost: "http://testnet.mba.cmbchina.biz:1337", wallet: walletModel)
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
                if !wallet.selectedTokenList.contains(where: { $0 == ethModel }) {
                    wallet.selectedTokenList.append(ethModel)
                }
            }
        }
    }

    func testChain(chainHost: String, wallet: WalletModel) {
        do {
            let metaData = try CITANetwork(url: URL(string: chainHost)).cita.rpc.getMetaData()
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
            chainModel.httpProvider = chainHost
            chainModel.nativeTokenIdentifier = tokenModel.identifier
            if let chainIdentifier = ChainModel.identifier(for: chainModel) {
                chainModel.identifier = chainIdentifier
            }
            tokenModel.chainIdentifier = chainModel.identifier

            let realm = try Realm()
            try realm.write {
                realm.add(tokenModel, update: true)
                realm.add(chainModel, update: true)
                if !wallet.chainModelList.contains(where: { $0 == chainModel }) {
                    wallet.chainModelList.append(chainModel)
                }
                if !wallet.tokenModelList.contains(where: { $0 == tokenModel }) {
                    wallet.tokenModelList.append(tokenModel)
                    if !wallet.selectedTokenList.contains(where: { $0 == tokenModel }) {
                        wallet.selectedTokenList.append(tokenModel)
                    }
                }
            }
        } catch {
        }

    }

}
