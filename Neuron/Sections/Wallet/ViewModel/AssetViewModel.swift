//
//  AssetViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AssetViewModel: NSObject {

    /// get assetList
    ///
    /// - Returns: list
    func getAssetListFromJSON() -> [TokenModel] {
        var tokenArray: [TokenModel] = []

        let appModel = WalletRealmTool.getCurrentAppmodel()
        for tModel in appModel.extraTokenList {
            try? WalletRealmTool.realm.write {
                WalletRealmTool.realm.add(tModel, update: true)
            }
            tokenArray.append(tModel)
        }

        let path = Bundle.main.path(forResource: "tokens-eth", ofType: "json")!
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return [] }
        guard let tokens = try? JSONDecoder().decode([TokenModel].self, from: jsonData) else { return [] }

        for token in tokens {
            token.chainidName = token.name
            token.iconUrl = token._logo?.src ?? ""
            tokenArray.append(token)
        }
        return tokenArray
    }

    func getSelectAsset() -> List<TokenModel>? {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        return appModel.currentWallet?.selectTokenList
    }

    func addSelectToken(tokenM: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        try? WalletRealmTool.realm.write {
            WalletRealmTool.realm.add(tokenM, update: true)
            appModel.currentWallet?.selectTokenList.append(tokenM)
        }
    }

    func deleteSelectedToken(tokenM: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        let filterResult = appModel.currentWallet?.selectTokenList.filter("address = %@", tokenM.address)
        try? WalletRealmTool.realm.write {
            WalletRealmTool.realm.add(tokenM, update: true)
            filterResult?.forEach({ (tm) in
                if let index = appModel.currentWallet?.selectTokenList.index(of: tm) {
                    appModel.currentWallet?.selectTokenList.remove(at: index)
                }
            })
        }

    }

}
