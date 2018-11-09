//
//  NervosNetwork.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import AppChain

struct NervosNetwork {
    private static let appHosts = "http://121.196.200.225:1337"

    static func getNervos(with urlString: String = appHosts) -> AppChain {
        let provider: HTTPProvider
        if urlString.isEmpty {
            provider = HTTPProvider(URL(string: appHosts)!)!
        } else {
            provider = HTTPProvider(URL(string: urlString)!)!
        }
        return AppChain(provider: provider)
    }
}
