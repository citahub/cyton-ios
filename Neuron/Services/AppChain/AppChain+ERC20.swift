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

    init(_ method: String, appChain: AppChain, contractAddress: String) {
        self.appChain = appChain
        self.contractAddress = contractAddress
    }

    func name() throws -> String {
        do {
            let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractData("name()"))
            let nameHex = try appChain.rpc.call(request: callRequest)
            let data = Data(hex: nameHex)
            return String(data: data, encoding: String.Encoding.utf8)!
        } catch let error {
            throw error
        }
    }

    func decimals() throws -> Int {
        do {
            let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractData("decimals()"))
            let decimalsHex = try appChain.rpc.call(request: callRequest)
            let bigUint = BigInt(decimalsHex)!
            return Int(bigUint)
        } catch let error {
            throw error
        }
    }

    func symbol() throws -> String? {
        do {
            let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractData("symbol()"))
            let symbolHex = try appChain.rpc.call(request: callRequest)
            let data = Data(hex: symbolHex)
            return String(data: data, encoding: String.Encoding.utf8)!
        } catch let error {
            throw error
        }
    }

    func getContractData(_ string: String) -> String {
        let data = string.data(using: String.Encoding.utf8)!
        let sha3 = data.sha3(.keccak256)
        let hexString = sha3.toHexString()
        let startIndex = hexString.startIndex
        let offset7Index = hexString.index(startIndex, offsetBy: 7)
        return String(hexString[startIndex...offset7Index])
    }
}
