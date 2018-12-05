//
//  ChainModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/5.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class ChainModel: Object {
    @objc dynamic var chainId = ""
    @objc dynamic var chainName = ""
    @objc dynamic var httpProvider = ""
}
