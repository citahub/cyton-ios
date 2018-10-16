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
    private static let appHosts = "http://121.196.200.225:1337"

    static func getNervos(with urlString: String = appHosts) -> Nervos {
        let provider: NervosProvider
        if urlString.isEmpty {
            provider = NervosProvider(URL(string: appHosts)!)!
        } else {
            provider = NervosProvider(URL(string: urlString)!)!
        }
        return Nervos(provider: provider)
    }
}
