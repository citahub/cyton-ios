//
//  EthNativeTokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import BigInt
import web3swift
import struct BigInt.BigUInt

struct EthNativeTokenService {
    /// get balance
    ///
    /// - Parameters:
    ///   - walletAddress: wallet address
    ///   - completion: EthServiceResult<BigUInt>
    static func getEthNativeTokenBalance(walletAddress: String, completion: @escaping (EthServiceResult<String>) -> Void) {
        let address = EthereumAddress(walletAddress)!
        let web3Main = Web3Network.getWeb3()
        DispatchQueue.global().async {
            let balanceResult = web3Main.eth.getBalance(address: address)
            DispatchQueue.main.async {
                switch balanceResult {
                case .success(let balance):
                    let balanceNumber = self.formatBalanceValue(value: balance)
                    completion(EthServiceResult.success(balanceNumber))
                case .failure(let error):
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
