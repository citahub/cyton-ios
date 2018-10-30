//
//  EthereumNetworkService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

struct EthereumNetworkService {
    let currentNetwork = "selectedNetwork"

    func setNetworkFirstLaunch() {
        let networkSelect = UserDefaults.standard.string(forKey: currentNetwork)
        if networkSelect == nil {
            UserDefaults.standard.set(NetworkServer.mainnet, forKey: currentNetwork)
        }
    }

    func saveSelectNetwork(_ network: String) {
        UserDefaults.standard.set(network, forKey: currentNetwork)
    }

    func getNetworkSelect() -> NetworkServer {
        let network = UserDefaults.standard.string(forKey: currentNetwork) ?? NetworkServer.mainnet.rawValue
        if network == NetworkServer.mainnet.rawValue {
            return NetworkServer.mainnet
        } else if network == NetworkServer.rinkeby.rawValue {
            return NetworkServer.rinkeby
        } else if network == NetworkServer.ropsten.rawValue {
            return NetworkServer.ropsten
        }
        return NetworkServer.mainnet
    }
}

enum NetworkServer: String {
    case mainnet
    case rinkeby
    case ropsten

    var rawValue: String {
        switch self {
        case .mainnet:
            return "mainnet"
        case .rinkeby:
            return "rinkeby"
        case .ropsten:
            return "ropsten"
        }
    }

    static let allValues = ["mainnet", "rinkeby", "ropsten"]
}
