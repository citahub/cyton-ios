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
    
    /// wallet name
    @objc dynamic var name = ""
    
    /// wallet address
    @objc dynamic var address = ""
    
    /// encrypt privatekey
    @objc dynamic var encryptPrivateKey = ""
    
    /// password MD5
    @objc dynamic var MD5screatPassword = ""
    
    /// icon data
    @objc dynamic var iconData:Data!
    
    override static func primaryKey() -> String? {
        return "address"
    }
}


