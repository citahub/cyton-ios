//
//  AssetViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class AssetViewModel: NSObject {
    
    /// get assetList
    ///
    /// - Returns: list
    func getAssetListFromJSON() -> [TokenModel]{
        
        let appModel = WalletRealmTool.getCurrentAppmodel()
        
        
        let path = Bundle.main.path(forResource: "tokens-eth", ofType: "json")!
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path))
        let jsonObj = try? JSON(data: jsonData!)
        
        var tokenArray:[TokenModel] = []
        
        for tModel in appModel.extraTokenList {
            try? WalletRealmTool.realm.write {
                tModel.name = (appModel.currentWallet?.name)!
            }
            tokenArray.append(tModel)
        }
        
        for (_, subJSON) : (String, JSON) in jsonObj! {
            let tokenModel = TokenModel()
            tokenModel.walletName = (appModel.currentWallet?.name)!
            tokenModel.name = subJSON["name"].stringValue
            tokenModel.address = subJSON["address"].stringValue
            tokenModel.decimals = subJSON["decimals"].intValue
            tokenModel.iconUrl = subJSON["logo"]["src"].stringValue
            tokenModel.symbol = subJSON["symbol"].stringValue
            tokenArray.append(tokenModel)
        }
        

        return tokenArray
    }
    
    func getSelectAsset() -> List<TokenModel>?{
        let appModel = WalletRealmTool.getCurrentAppmodel()
        return appModel.currentWallet?.selectTokenList
    }
    
    func addSelectToken(tokenM:TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        try? WalletRealmTool.realm.write {
            appModel.currentWallet?.selectTokenList.append(tokenM)
        }
    }
    
    func deleteSelectedToken(tokenM:TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        for tokenModel in appModel.currentWallet!.selectTokenList {
            if tokenM.address == tokenModel.address {
                try? WalletRealmTool.realm.write {
                        WalletRealmTool.realm.delete(tokenModel)
                }
            }
        }
        
    }
    
}
