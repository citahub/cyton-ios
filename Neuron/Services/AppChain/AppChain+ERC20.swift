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
        let callRequest = CallRequest(from: AppModel.current.currentWallet?.address, to: self.contractAddress, data: getContractString("name()"))
        let nameHex = try appChain.rpc.call(request: callRequest)
        let data = Data(hex: nameHex)
        return String(data: data, encoding: .utf8)
    }

    func decimals() throws -> BigUInt? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractString("decimals()"))
        let decimalsHex = try appChain.rpc.call(request: callRequest)
        return decimalsHex.toBigUInt()
    }

    func symbol() throws -> String? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractString("symbol()"))
        let symbolHex = try appChain.rpc.call(request: callRequest)
        let data = Data(hex: symbolHex)
        print(String(data: data, encoding: String.Encoding.utf8))
        return String(data: data, encoding: String.Encoding.utf8)
    }

    func balance(walletAddress: String) -> String {
        if !Address.isValid(walletAddress) {
            fatalError()
        }
        var data = Data()
        let funcNameData = getContractData("balanceOf()")
        data.append(funcNameData)
        let addressData = Data(hex: walletAddress.addHexPrefix())
        let padding = ((addressData.count + 31) / 32) * 32 - addressData.count
        data.append(Data(repeating: 0, count: padding))
        data.append(addressData)
        return data.toHexString()
    }

    func getContractString(_ string: String) -> String {
        let data = string.data(using: .utf8)!
        let sha3 = data.sha3(.keccak256)
        let hexString = sha3.toHexString()
        return String(hexString.prefix(8)).addHexPrefix()
    }

    func getContractData(_ string: String) -> Data {
        let data = string.data(using: .utf8)!
        let sha3 = data.sha3(.keccak256)
        return sha3[0..<4]
    }
}
