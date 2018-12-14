//
//  AppChainBalanceLoader.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

class AppChainBalanceLoader {
    private let appChain: AppChain
    private let walletAddress: String

    init(appChain: AppChain, address: String) {
        self.appChain = appChain
        self.walletAddress = address
    }

    func getBalance() throws -> BigUInt {
        return try appChain.rpc.getBalance(address: walletAddress)
    }

    func getERC20Balance(contractAddress: String) throws -> BigUInt {
        let appchainERC20 = AppChainERC20(appChain: appChain, contractAddress: contractAddress)
        let callRequest = CallRequest(from: nil, to: contractAddress, data: appchainERC20.balance(walletAddress: walletAddress))
        let balanceHex = try appChain.rpc.call(request: callRequest)
        return balanceHex.toBigUInt() ?? 0
    }
}
