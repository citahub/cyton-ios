//
//  AppModel.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/13.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AppModel: Object {
    @objc dynamic var currentWallet: WalletModel?

    /// whole wallet list
    var wallets = List<WalletModel>()

    static var current: AppModel {
        let realm = try! Realm()
        return realm.objects(AppModel.self).first ?? AppModel()
    }
}
