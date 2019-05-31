//
//  EthereumBalanceLoader.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/29.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import web3swift

class EthereumBalanceLoader {
    private let web3: web3
    private let walletAddress: String

    init(web3: web3, address: String) {
        self.web3 = web3
        walletAddress = address
    }

    func getBalance() throws -> BigUInt {
        return try web3.eth.getBalance(address: EthereumAddress(walletAddress)!)
    }

    func getTokenBalance(address: String) throws -> BigUInt {
        let contractAddress = EthereumAddress(address)!
        let walletAddress = EthereumAddress(self.walletAddress)!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
        let result = try contract.method("balanceOf", parameters: [walletAddress as AnyObject])?.call()
        return result?["0"] as! BigUInt
    }
}
