//
//  AppChain+ERC20.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/3.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

class AppChainERC20 {
    private let appChain: AppChain
    private let contractAddress: String

    init(appChain: AppChain, contractAddress: String) {
        self.appChain = appChain
        self.contractAddress = contractAddress
    }

    func name() throws -> String? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractData("name()"))
        let nameHex = try appChain.rpc.call(request: callRequest)
        let data = Data(hex: nameHex)
        return String(data: data, encoding: String.Encoding.utf8)
    }

    func decimals() throws -> BigUInt? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractData("decimals()"))
        let decimalsHex = try appChain.rpc.call(request: callRequest)
        return BigUInt(decimalsHex)
    }

    func symbol() throws -> String? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractData("symbol()"))
        let symbolHex = try appChain.rpc.call(request: callRequest)
        let data = Data(hex: symbolHex)
        return String(data: data, encoding: String.Encoding.utf8)
    }

    func getContractData(_ string: String) -> String {
        let data = string.data(using: String.Encoding.utf8)!
        let sha3 = data.sha3(.keccak256)
        let hexString = sha3.toHexString()
        return String(hexString.prefix(8))
    }
}
