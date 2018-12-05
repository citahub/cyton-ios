//
//  WalletModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class WalletModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var address = ""
    @objc dynamic var iconData: Data!
    var selectTokenList = List<TokenModel>()
    var tokenModelList = List<TokenModel>()
    var chainModelList = List<ChainModel>()

    var wallet: Wallet? {
        return WalletManager.default.wallet(for: address)
    }

    override static func primaryKey() -> String? {
        return "address"
    }
}
