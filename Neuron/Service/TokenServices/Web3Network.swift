//
//  Web3Network.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift

struct Web3Network {
    func getWeb3() -> web3 {
        let selectedNetwork = getCurrentNetwork()
        switch selectedNetwork {
        case .mainnet:
            return Web3.InfuraMainnetWeb3()
        case .rinkeby:
            return Web3.InfuraRinkebyWeb3()
        case .ropsten:
            return Web3.InfuraRopstenWeb3()
        }
    }

    private let currentNetworkKey = "selectedNetwork"

    func setNetworkFirstLaunch() {
        let networkSelect = UserDefaults.standard.string(forKey: currentNetworkKey)
        if networkSelect == nil {
            UserDefaults.standard.set(NetworkServer.mainnet.rawValue, forKey: currentNetworkKey)
        }
    }

    func saveSelectNetwork(_ network: String) {
        UserDefaults.standard.set(network, forKey: currentNetworkKey)
    }

    func getCurrentNetwork() -> NetworkServer {
        let network = UserDefaults.standard.string(forKey: currentNetworkKey) ?? NetworkServer.mainnet.rawValue
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
