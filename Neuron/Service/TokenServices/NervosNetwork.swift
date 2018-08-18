//
//  NervosNetwork.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Nervos

class NervosNetwork {
    static public func getNervos() -> Nervos {
        let provider = NervosProvider(URL(string: "http://121.196.200.225:1337")!)!
        return Nervos(provider: provider)
    }
}
