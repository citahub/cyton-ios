//
//  CITA+ERC20.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/3.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import CITA
import web3swift
import BigInt

class CITAERC20 {
    private let cita: CITA
    private let contractAddress: String
    private let contract: EthereumContract

    init(cita: CITA, contractAddress: String) {
        self.cita = cita
        self.contractAddress = contractAddress
        self.contract = EthereumContract(Web3Utils.erc20ABI)!
    }

    func name() throws -> String? {
        let callRequest = CallRequest(from: AppModel.current.currentWallet?.address, to: self.contractAddress, data: getContractString("name()"))
        let nameHex = try cita.rpc.call(request: callRequest)
        let data = Data(hex: nameHex)
        let result = contract.decodeReturnData("name", data: data)
        return result?.first?.value as? String
    }

    func decimals() throws -> BigUInt? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractString("decimals()"))
        let decimalsHex = try cita.rpc.call(request: callRequest)
        return decimalsHex.toBigUInt()
    }

    func symbol() throws -> String? {
        let callRequest = CallRequest(from: nil, to: self.contractAddress, data: getContractString("symbol()"))
        let symbolHex = try cita.rpc.call(request: callRequest)
        let data = Data(hex: symbolHex)
        let result = contract.decodeReturnData("symbol", data: data)
        return result?.first?.value as? String
    }

    func balance() throws -> BigUInt? {
        let walletAddress = AppModel.current.currentWallet!.address
        let data = encodeInputs(method: "balanceOf", parameters: [walletAddress as AnyObject])!
        let dataHex = data.toHexString().prefix(8)
        let callRequest = CallRequest(from: walletAddress, to: contractAddress, data: String(dataHex).addHexPrefix() + String(repeating: "0", count: 24) + walletAddress.removeHexPrefix())
        let balanceHex = try cita.rpc.call(request: callRequest)
        return balanceHex.toBigUInt() ?? 0
    }

    func transferData(to: String, amount: BigUInt) throws -> Data? {
        guard let erc20Contract = EthereumContract(Web3Utils.erc20ABI, at: EthereumAddress(contractAddress)) else {
            return nil
        }
        guard let to = EthereumAddress(to) else { return nil }
        let data = encodeInputs(ethereumContract: erc20Contract, method: "transfer", parameters: [to, amount] as [AnyObject])
        return data
    }

    func getContractString(_ string: String) -> String {
        let data = string.data(using: .utf8)!
        let sha3 = data.sha3(.keccak256)
        let hexString = sha3.toHexString()
        return String(hexString.prefix(8)).addHexPrefix()
    }

    func encodeInputs(ethereumContract: EthereumContract = EthereumContract(Web3Utils.erc20ABI)!, method: String, parameters: [AnyObject] = [AnyObject]()) -> Data? {
        let foundMethod = ethereumContract.methods.filter { (key, _) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else { return Data() }
        let abiMethod = foundMethod[method]
        return abiMethod?.encodeParameters(parameters)
    }

}
