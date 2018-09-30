//
//  CustomERC20TokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/5.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol CustomERC20TokenServiceProtocol {
    static func decimals(walletAddress: String, token: String, completion:@escaping (EthServiceResult<BigUInt>) -> Void)
    static func name(walletAddress: String, token: String, completion:@escaping (EthServiceResult<String>) -> Void)
    static func symbol(walletAddress: String, token: String, completion:@escaping (EthServiceResult<String>) -> Void)
}

class CustomERC20TokenService: CustomERC20TokenServiceProtocol {

    static func decimals(walletAddress: String, token: String, completion: @escaping (EthServiceResult<BigUInt>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(ERC20Token: token)
            let transaction = contract?.method("decimals", parameters: [AnyObject](), options: self.defaultOptions(wAddress: walletAddress))
            let decimals = transaction?.call(options: self.defaultOptions(wAddress: walletAddress))
            DispatchQueue.main.async {
                if let decimals = decimals?.value?["0"] as? BigUInt {
                    completion(EthServiceResult.Success(decimals))
                } else {
                    completion(EthServiceResult.Error(CustomTokenError.wrongBalanceError))
                }
            }
        }
    }

    static func name(walletAddress: String, token: String, completion: @escaping (EthServiceResult<String>) -> Void) {
        let contract = self.contract(ERC20Token: token)
        if let transaction = contract?.method("name", parameters: [AnyObject](), options: self.defaultOptions(wAddress: walletAddress)) {

            let reult = transaction.call(options: self.defaultOptions(wAddress: walletAddress), onBlock: "latest")
            switch reult {
            case .success(let name):

                if let names = name["0"] as? String, !names.isEmpty {
                    completion(EthServiceResult.Success(names))
                } else {
                    completion(EthServiceResult.Error(CustomTokenError.badNameError))
                }
            case .failure(let error):
                completion(EthServiceResult.Error(error))
            }
        } else {
            completion(EthServiceResult.Error(CustomTokenError.badNameError))
        }
    }

    static func symbol(walletAddress: String, token: String, completion: @escaping (EthServiceResult<String>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(ERC20Token: token)
            let transaction = contract?.method("symbol", parameters: [AnyObject](), options: self.defaultOptions(wAddress: walletAddress))
            let symbol = transaction?.call(options: self.defaultOptions(wAddress: walletAddress))
            DispatchQueue.main.async {
                if let symbol = symbol?.value?["0"] as? String, !symbol.isEmpty {
                    completion(EthServiceResult.Success(symbol))
                } else {
                    completion(EthServiceResult.Error(CustomTokenError.badSymbolError))
                }
            }
        }
    }

    private static func contract(ERC20Token: String) -> web3.web3contract? {
        let web3 = Web3Network.getWeb3()
        guard let contractETHAddress = EthereumAddress(ERC20Token) else {
            return nil
        }
        return web3.contract(Web3.Utils.erc20ABI, at: contractETHAddress, abiVersion: 2)
    }

    private static func defaultOptions(wAddress: String) -> Web3Options {
        var options = Web3Options.defaultOptions()
        options.from = EthereumAddress(wAddress)
        return options
    }

}
