//
//  WalletRealmTool.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/19.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

struct WalletRealmTool {
    /// addAppModel
    ///
    /// - Parameter appModel: appmodel instance
    static func addObject(appModel: AppModel) {
        let realm = try! Realm()
        realm.add(appModel)
    }

    /// Add token model
    ///
    /// - Parameter tokenModel: tokenModel instance
    static func addTokenModel(tokenModel: TokenModel) {
        let realm = try! Realm()
        let result = realm.objects(AppModel.self).first
        if let appModel = result {
            var totalTokenList: [TokenModel] = []
            totalTokenList += appModel.nativeTokenList
            totalTokenList += appModel.extraTokenList
            // tokenModel.identifier is always exist
            if let model = totalTokenList.first(where: { $0 == tokenModel }) {
                tokenModel.identifier = model.identifier
            }
            realm.add(tokenModel, update: true)
        }
    }
}
