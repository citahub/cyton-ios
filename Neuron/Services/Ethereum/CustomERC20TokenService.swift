//
//  CustomERC20TokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/5.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import struct BigInt.BigUInt

struct CustomERC20TokenService {
    static func decimals(walletAddress: String, token: String, completion: @escaping (EthServiceResult<BigUInt>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(ERC20Token: token)!
            var options = TransactionOptions()
            options.from = EthereumAddress(walletAddress)
            let transaction = contract.method("decimals", parameters: [AnyObject]())!
            do {
                let decimals = try transaction.call(transactionOptions: options)
                if let decimals = decimals["0"] as? BigUInt {
                    DispatchQueue.main.async {
                        completion(EthServiceResult.success(decimals))
                    }
                } else {
                    throw CustomTokenError.wrongBalanceError
                }
            } catch {
                DispatchQueue.main.async {
                    completion(EthServiceResult.error(CustomTokenError.wrongBalanceError))
                }
            }
        }
    }

    static func name(walletAddress: String, token: String, completion: @escaping (EthServiceResult<String>) -> Void) {
        let contract = self.contract(ERC20Token: token)!
        if let transaction = contract.method("name", parameters: [AnyObject]()) {
            var options = TransactionOptions()
            options.from = EthereumAddress(walletAddress)
            do {
                let name = try transaction.call(transactionOptions: options)
                if let names = name["0"] as? String, !names.isEmpty {
                    completion(EthServiceResult.success(names))
                } else {
                    throw CustomTokenError.badNameError
                }
            } catch {
                completion(EthServiceResult.error(CustomTokenError.badNameError))
            }
        } else {
            completion(EthServiceResult.error(CustomTokenError.badNameError))
        }
    }

    static func symbol(walletAddress: String, token: String, completion: @escaping (EthServiceResult<String>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(ERC20Token: token)!
            let transaction = contract.method("symbol", parameters: [AnyObject]())!
            var options = TransactionOptions()
            options.from = EthereumAddress(walletAddress)
            do {
                let symbol = try transaction.call(transactionOptions: options)
                if let symbol = symbol["0"] as? String, !symbol.isEmpty {
                    DispatchQueue.main.async {
                        completion(EthServiceResult.success(symbol))
                    }
                } else {
                    throw CustomTokenError.badSymbolError
                }
            } catch {
                DispatchQueue.main.async {
                    completion(EthServiceResult.error(CustomTokenError.badSymbolError))
                }
            }
        }
    }

    private static func contract(ERC20Token: String) -> web3.web3contract? {
        let web3 = EthereumNetwork().getWeb3()
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
