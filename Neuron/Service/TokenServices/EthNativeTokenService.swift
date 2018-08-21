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

protocol EthNativeTokenServiceProtocol {
    static func getEthNativeTokenBalance(walletAddress: String, completion:@escaping(EthServiceResult<BigUInt>) -> Void)
}

class EthNativeTokenService: EthNativeTokenServiceProtocol {

    /// get balance
    ///
    /// - Parameters:
    ///   - walletAddress: wallet address
    ///   - completion: EthServiceResult<BigUInt>
    static func getEthNativeTokenBalance(walletAddress: String, completion: @escaping (EthServiceResult<BigUInt>) -> Void) {
        let address = EthereumAddress(walletAddress)!
        let web3Main = Web3NetWork.getWeb3()
        DispatchQueue.global().async {
            let balanceResult = web3Main.eth.getBalance(address: address)
            DispatchQueue.main.async {
                switch balanceResult {
                case .success(let balance):
                    completion(EthServiceResult.Success(balance))
                case .failure(let error):
                    completion(EthServiceResult.Error(error))
                }
            }
        }
    }

}
