//
//  Web3Network.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift

class Web3Network {
    public static func getWeb3() -> web3 {
        return Web3.InfuraMainnetWeb3()
    }
}
