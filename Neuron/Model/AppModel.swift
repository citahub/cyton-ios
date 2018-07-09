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
    
    
    /// current wallet
    @objc dynamic var currentWallet : WalletModel?
    
    /// whole wallet list
    var wallets = List<WalletModel>()
    
    /// whole wallet extra asset token list does not include tokens-eth.json's token
    var extraTokenList = List<TokenModel>()
}
