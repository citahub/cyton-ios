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

    /// according to wallet address to get WalletModel
    ///
    /// - Parameter walletName: walletName
    /// - Returns: WalletModel
    static func getCreatWallet(walletAddress: String) -> WalletModel {
        var walletModel = WalletModel()
        walletModel = realm.object(ofType: WalletModel.self, forPrimaryKey: walletAddress)!
        return walletModel
    }

    /// get everything for AppModel
    ///
    /// - Returns: appmodel
    static func getCurrentAppmodel() -> AppModel {
//        if isHasWallet() {
        let result = realm.objects(AppModel.self)
        if result.count == 0 {
            return AppModel()
        } else {
            let appModel: AppModel = result[0]
            return appModel
        }
//        }else{
//            return AppModel()
//        }
    }

    /// update currentWallet
    ///
    /// - Parameter walletName: wallet name
    static func updateAppCurrentWallet(walletAddress: String) {
        let result = realm.objects(AppModel.self)
        let appModel: AppModel = result[0]
        try! realm.write {
            appModel.currentWallet = getCreatWallet(walletAddress: walletAddress)
        }
    }

    /// 判断当前app中是否有钱包
    ///
    /// - Returns: true or false
    static func isHasWallet() -> Bool {
        let result = realm.objects(AppModel.self)
        if result.count == 0 {
            return false
        } else {
            let appModel: AppModel = result[0]
            if appModel.wallets.count == 0 {
                return false
            } else {
                return true
            }
        }
    }

    /// addAppModel
    ///
    /// - Parameter appModel: appmodel instance
    static func addObject(appModel: AppModel) {
            realm.add(appModel)
    }

}
