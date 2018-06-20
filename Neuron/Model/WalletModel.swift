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
    
    /// 钱包名称
    @objc dynamic var name = ""
    
    /// 钱包密码
    @objc dynamic var password = ""
    
    /// 钱包地址
    @objc dynamic var address = ""
    
    /// 钱包私钥
    @objc dynamic var privateKey = ""
    
    /// keystore
    @objc dynamic var keyStore = ""
    
    /// 钱包助记词
    @objc dynamic var mnemonic = ""
    
    /// 根据钱包名称生成的头像
    @objc dynamic var iconData:Data!
    
    override static func primaryKey() -> String? {
        return "address"
    }
    
}


