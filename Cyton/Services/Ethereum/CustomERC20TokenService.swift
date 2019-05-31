//
//  CustomERC20TokenService.swift
//  Cyton
//
//  Created by XiaoLu on 2018/7/5.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import BigInt

enum CustomTokenError: String, LocalizedError {
    case wrongBalanceError
    case badNameError
    case badSymbolError
    case undefinedError

    var errorDescription: String? {
        return "CustomTokenError.\(rawValue)".localized()
    }
}

struct CustomERC20TokenService {
    static func searchTokenData(contractAddress: String, walletAddress: String) throws -> TokenModel {
        let contractAddress = contractAddress.addHexPrefix()
        guard EthereumAddress(contractAddress) != nil else {
            throw CustomTokenError.undefinedError
        }

        let tokenModel = TokenModel()
        if let name = callTransaction(contractAddress: contractAddress, walletAddress: walletAddress, method: "name") as? String {
            tokenModel.name = name
        } else {
            throw CustomTokenError.badNameError
        }

        tokenModel.symbol = callTransaction(contractAddress: contractAddress, walletAddress: walletAddress, method: "symbol") as? String ?? ""

        if let decimals = callTransaction(contractAddress: contractAddress, walletAddress: walletAddress, method: "decimals") as? BigUInt {
            tokenModel.decimals = Int(decimals)
        } else {
            throw CustomTokenError.wrongBalanceError
        }
        tokenModel.address = contractAddress
        tokenModel.isNativeToken = false
        guard !tokenModel.name.isEmpty else {
            throw CustomTokenError.undefinedError
        }
        return tokenModel
    }

    private static func callTransaction(contractAddress: String, walletAddress: String, method: String) -> Any? {
        let contract = self.contract(ERC20Token: contractAddress)!
        if let transaction = contract.method(method, parameters: [AnyObject]()) {
            var options = TransactionOptions()
            options.from = EthereumAddress(walletAddress)
            if let result = try? transaction.call(transactionOptions: options) {
                return result["0"]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    private static func contract(ERC20Token: String) -> web3.web3contract? {
        let web3 = EthereumNetwork().getWeb3()
        guard let contractETHAddress = EthereumAddress(ERC20Token) else {
            return nil
        }
        return web3.contract(Web3.Utils.erc20ABI, at: contractETHAddress, abiVersion: 2)
    }

    private static func defaultOptions(wAddress: String) -> TransactionOptions {
        var options = TransactionOptions.defaultOptions
        options.from = EthereumAddress(wAddress)
        return options
    }
}
