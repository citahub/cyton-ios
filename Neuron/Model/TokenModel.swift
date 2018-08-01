//
//  TokenModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt

class TokenModel: Object {
    
    // because import and creat wallet will check wallet name,  this can use wallet name
    @objc dynamic var tokenBalance = ""
    @objc dynamic var name = ""
    @objc dynamic var iconUrl:String? = ""
    @objc dynamic var address = ""
    @objc dynamic var decimals = 0
    @objc dynamic var symbol = ""
    @objc dynamic var chainName:String? = ""
    @objc dynamic var chainidName = "" // chainId + name
    @objc dynamic var chainId = ""
    
    // defaults false, eth and RPC "getMateData" is true.
    @objc dynamic var isNativeToken = false
    
    override class func primaryKey() -> String? {
        return "chainidName"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["tokenBalance"]
    }
}

