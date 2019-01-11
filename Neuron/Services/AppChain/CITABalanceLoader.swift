//
//  CITABalanceLoader.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import CITA
import BigInt

class CITABalanceLoader {
    private let cita: CITA
    private let walletAddress: String

    init(cita: CITA, address: String) {
        self.cita = cita
        self.walletAddress = address
    }

    func getBalance() throws -> BigUInt {
        return try cita.rpc.getBalance(address: walletAddress)
    }

    func getERC20Balance(contractAddress: String) throws -> BigUInt {
        return try CITAERC20(cita: cita, contractAddress: contractAddress).balance() ?? 0
    }
}
