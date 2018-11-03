//
//  Web3Network.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Web3swift

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

    public enum EthereumNetworkType: String {
        case mainnet
        case rinkeby
        case ropsten

        static let allValues = ["mainnet", "rinkeby", "ropsten"]
    }

    private let currentNetworkKey = "selectedNetwork"

    func setNetworkFirstLaunch() {
        let networkSelect = UserDefaults.standard.string(forKey: currentNetworkKey)
        if networkSelect == nil {
            UserDefaults.standard.set(EthereumNetworkType.mainnet.rawValue, forKey: currentNetworkKey)
        }
    }

    func saveSelectNetwork(_ network: String) {
        UserDefaults.standard.set(network, forKey: currentNetworkKey)
    }

    func getCurrentNetwork() -> EthereumNetworkType {
        let network = UserDefaults.standard.string(forKey: currentNetworkKey) ?? ""
        return EthereumNetworkType(rawValue: network) ?? .mainnet
    }
}
