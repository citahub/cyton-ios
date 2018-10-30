//
//  TAViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

class TAViewModel {
    func getGasPrice(completion:@escaping (EthServiceResult<BigUInt>) -> Void) {
        let web3 = Web3Network().getWeb3()
        DispatchQueue.global().async {
            let gasPriceResult = web3.eth.getGasPrice()
            DispatchQueue.main.async {
                switch gasPriceResult {
                case .success(let gasPrice):
                    completion(EthServiceResult.success(gasPrice))
                case .failure(let error):
                    completion(EthServiceResult.error(error))
                }
            }
        }
    }
}
