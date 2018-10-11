//
//  WKWebViewConfigConstants.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

enum DAppServer {
    case main

    var name: String {
        switch self {
        case .main:
            return "ethereum"
        }
    }

    var symbol: String {
        switch self {
        case .main:
            return "ETH"
        }
    }

    var chainID: Int {
        switch self {
        case .main:
            return 1
        }
    }

    var rpcRul: String {
        switch self {
        case .main:
            return "https://mainnet.infura.io/h3iIzGIN6msu3KeUrdlt"
        }
    }
}
