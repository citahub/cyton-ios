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

        let appModel = WalletRealmTool.getCurrentAppModel()
        for tokenModel in appModel.extraTokenList {
            try? WalletRealmTool.realm.write {
                WalletRealmTool.addTokenModel(tokenModel: tokenModel)
            }
            tokenArray.append(tokenModel)
        }

        let path = Bundle.main.path(forResource: "tokens-eth", ofType: "json")!
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return [] }
        guard let tokens = try? JSONDecoder().decode([TokenModel].self, from: jsonData) else { return [] }

        for token in tokens {
            token.iconUrl = token.logo?.src ?? ""
            tokenArray.append(token)
        }
        return tokenArray
    }

    func getSelectAsset() -> List<TokenModel>? {
        let appModel = WalletRealmTool.getCurrentAppModel()
        return appModel.currentWallet?.selectTokenList
    }

    func addSelectToken(tokenModel: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppModel()
        try? WalletRealmTool.realm.write {
            WalletRealmTool.addTokenModel(tokenModel: tokenModel)
            appModel.currentWallet?.selectTokenList.append(tokenModel)
        }
    }

    func deleteSelectedToken(tokenModel: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let filterResult = appModel.currentWallet?.selectTokenList.filter("address = %@", tokenModel.address)
        try? WalletRealmTool.realm.write {
            WalletRealmTool.addTokenModel(tokenModel: tokenModel)
            filterResult?.forEach({ (tm) in
                if let index = appModel.currentWallet?.selectTokenList.index(of: tm) {
                    appModel.currentWallet?.selectTokenList.remove(at: index)
                }
            })
        }

    }

}
