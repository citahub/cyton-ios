//
//  EthNativeTokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import BigInt
import Web3swift
import EthereumAddress

// TODO: create balanceLoader
struct EthNativeTokenService {
    /// get balance
    ///
    /// - Parameters:
    ///   - walletAddress: wallet address
    ///   - completion: EthServiceResult<BigUInt>
    static func getEthNativeTokenBalance(walletAddress: String, completion: @escaping (EthServiceResult<String>) -> Void) {
        let address = EthereumAddress(walletAddress)!
        let web3Main = EthereumNetwork().getWeb3()
        DispatchQueue.global().async {
            do {
                let balance = try web3Main.eth.getBalance(address: address)
                DispatchQueue.main.async {
                    completion(EthServiceResult.success(self.formatBalanceValue(value: balance)))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(EthServiceResult.error(error))
                }
            }
        }
    }

    private static func formatBalanceValue(value: BigUInt) -> String {
        let format = Web3.Utils.formatToPrecision(value, formattingDecimals: 8, fallbackToScientific: false)!
        let finalValue = Double(format)!
        return finalValue.clean
    }
}
