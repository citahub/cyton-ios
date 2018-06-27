//
//  AppModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/13.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AppModel: Object {
    
    
    /// 当前app显示的钱包
    @objc dynamic var currentWallet : WalletModel?

    /// 整个app中的钱包列表
    var wallets = List<WalletModel>()
    
    
    
}
