//
//  WalletRealmTool.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/19.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class WalletRealmTool: NSObject {
    
    static let realm = RealmHelper.sharedInstance
    
    /// 根据钱包name去取钱包
    ///
    /// - Parameter walletName: walletName
    /// - Returns: WalletModel
    static func getCreatWallet(walletAddress:String) -> WalletModel{
        var walletModel = WalletModel()
        walletModel = realm.object(ofType: WalletModel.self, forPrimaryKey: walletAddress)!
        return walletModel
    }
    
    /// 获取当前AppModel的所有内容
    ///
    /// - Returns: appmodel
    static func getCurrentAppmodel() -> AppModel{
        let result = realm.objects(AppModel.self)
        let appModel:AppModel = result[0]
        return appModel
    }
    
    /// 更新appmodel的当前钱包
    ///
    /// - Parameter walletName: wallet name
    static func updateAppCurrentWallet(walletAddress:String){
        let result = realm.objects(AppModel.self)
        let appModel:AppModel = result[0]
        try! realm.write {
            appModel.currentWallet = getCreatWallet(walletAddress: walletAddress)
        }
    }
    
    /// 判断当前app中是否有钱包
    ///
    /// - Returns: true or false
    static func isHasWallet() -> Bool{
        let result = realm.objects(AppModel.self)
        if result.count == 0 {
            return false
        }else{
            let appModel:AppModel = result[0]
            if appModel.wallets.count == 0 {
                return false
            }else{
                return true
            }
        }
    }
    
}
