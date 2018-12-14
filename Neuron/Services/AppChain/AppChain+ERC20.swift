//
//  AppChain+ERC20.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/3.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import Web3swift
import EthereumAddress
import BigInt

class AppChainERC20 {
    private let appChain: AppChain
    private let contractAddress: String
    private let contract: EthereumContract

    init(appChain: AppChain, contractAddress: String) {
        self.appChain = appChain
        self.contractAddress = contractAddress
        self.contract = EthereumContract(Web3Utils.erc20ABI)!
    }

    func name() throws -> String? {
        let callRequest = CallRequest(from: AppModel.current.currentWallet?.address, to: self.contractAddress, data: getContractString("name()"))
        let nameHex = try appChain.rpc.call(request: callRequest)
        let data = Data(hex: nameHex)
        let result = contract.decodeReturnData("name", data: data)
        return result?.first?.value as? String
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
        let result = contract.decodeReturnData("symbol", data: data)
        return result?.first?.value as? String
    }

    func balance(walletAddress: String) -> String {
        if !Address.isValid(walletAddress) {
            fatalError()
        }
        let dataHex = encodeInputs(method: "balanceOf", parameters: [walletAddress as AnyObject])!.toHexString()
        return String(dataHex.prefix(8)).addHexPrefix()
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

    func encodeInputs(method: String, parameters: [AnyObject] = [AnyObject]()) -> Data? {
        let foundMethod = contract.methods.filter { (key, _) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else { return Data() }
        let abiMethod = foundMethod[method]
        return abiMethod?.encodeParameters(parameters)
    }

}
