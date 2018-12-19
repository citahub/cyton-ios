//
//  EthereumNetwork.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Web3swift

class EthereumNetwork {
    func getWeb3() -> web3 {
        switch networkType {
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

    func apiHost() -> URL {
        switch networkType {
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

    func host() -> URL {
        switch networkType {
        case .mainnet:
            return URL(string: "https://etherscan.io")!
        case .rinkeby:
            return URL(string: "https://rinkeby.etherscan.io")!
        case .ropsten:
            return URL(string: "https://ropsten.etherscan.io")!
        case .kovan:
            return URL(string: "https://kovan.etherscan.io")!
        }
    }

    enum EthereumNetworkType: String, CaseIterable {
        case mainnet
        case rinkeby
        case ropsten
        case kovan

        var chainName: String {
            switch self {
            case .mainnet:
                return "Main Ethereum Network"
            case .rinkeby:
                return "Rinkeby Test Network"
            case .ropsten:
                return "Ropsten Test Network "
            case .kovan:
                return "Kovan Test Network"
            }
        }
    }

    private let currentNetworkKey = "ethereumNetwork"

    var networkType: EthereumNetworkType {
        get {
            let network = UserDefaults.standard.string(forKey: currentNetworkKey) ?? ""
            return EthereumNetworkType(rawValue: network) ?? .mainnet
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: currentNetworkKey)
            NotificationCenter.default.post(name: .switchEthNetwork, object: nil)
        }
    }
}
