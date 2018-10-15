//
//  NervosNetwork.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Nervos

struct NervosNetwork {
    static func getNervos(with urlString: String = "http://121.196.200.225:1337") -> Nervos {
        let provider = NervosProvider(URL(string: urlString)!)!
        return Nervos(provider: provider)
    }
}
