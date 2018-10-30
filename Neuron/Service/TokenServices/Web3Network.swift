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
    static func getWeb3() -> web3 {
        let selectedNetwork = EthereumNetworkService().getNetworkSelect()
        switch selectedNetwork {
        case .mainnet:
            return Web3.InfuraMainnetWeb3()
        case .rinkeby:
            return Web3.InfuraRinkebyWeb3()
        case .ropsten:
            return Web3.InfuraRopstenWeb3()
        }
    }
}
