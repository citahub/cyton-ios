//
//  EthereumNetwork.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Web3swift

struct EthereumNetwork {
    func getWeb3() -> web3 {
        switch currentNetwork {
        case .mainnet:
            return Web3.InfuraMainnetWeb3()
        case .rinkeby:
            return Web3.InfuraRinkebyWeb3()
        case .ropsten:
            return Web3.InfuraRopstenWeb3()
        case .kovan:
            let infura = InfuraProvider(.Kovan)!
            return web3(provider: infura)
        }
    }

    func host() -> URL {
        switch currentNetwork {
        case .mainnet:
            return URL(string: "http://api.etherscan.io")!
        case .rinkeby:
            return URL(string: "http://api-rinkeby.etherscan.io")!
        case .ropsten:
            return URL(string: "http://api-ropsten.etherscan.io")!
        case .kovan:
            return URL(string: "http://api-kovan.etherscan.io")!
        }
    }

    enum EthereumNetworkType: String, CaseIterable {
        case mainnet
        case rinkeby
        case ropsten
        case kovan

        static let allValues = allCases.map { $0.rawValue }
        var chainName: String {
            switch self {
            case .mainnet:
                return "Ethereum Mainnet"
            case .rinkeby:
                return "Ethereum Rinkebynet"
            case .ropsten:
                return "Ethereum Ropstennet"
            case .kovan:
                return "Ethereum Kovannet"
            }
        }
    }

    private let currentNetworkKey = "selectedNetwork"

    var currentNetwork: EthereumNetworkType {
        let network = UserDefaults.standard.string(forKey: currentNetworkKey) ?? ""
        return EthereumNetworkType(rawValue: network) ?? .mainnet
    }

    func switchNetwork(_ network: String) {
        if let network = EthereumNetworkType(rawValue: network) {
            UserDefaults.standard.set(network.rawValue, forKey: currentNetworkKey)
        }
    }
}
