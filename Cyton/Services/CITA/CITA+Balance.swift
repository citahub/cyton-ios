//
//  CITABalanceLoader.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import CITA
import BigInt

extension CITANetwork {
    func getBalance(walletAddress: String) throws -> BigUInt {
        return try cita.rpc.getBalance(address: walletAddress)
    }

    func getErc20Balance(walletAddress: String, contractAddress: String) throws -> BigUInt {
        return try CITAERC20(cita: cita, contractAddress: contractAddress).balance() ?? 0
    }
}
