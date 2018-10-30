//
//  ERC20TokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/4.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

struct ERC20TokenService {
    /// getBalance
    ///
    /// - Parameters:
    ///   - walletAddress: wallet public key
    ///   - contractAddress: token address
    ///   - completion: balance result
    static func getERC20TokenBalance(walletAddress: String, contractAddress: String, completion: @escaping (EthServiceResult<BigUInt>) -> Void) {
        let web3 = Web3Network().getWeb3()
        let contractETHAddress = EthereumAddress(contractAddress)!
        let coldWalletAddress = EthereumAddress(walletAddress)
        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractETHAddress, abiVersion: 2)
        let options = Web3Options.defaultOptions()

        DispatchQueue.global().async {
            guard let result = contract?.method("balanceOf", parameters: [coldWalletAddress as AnyObject], options: options)?.call(options: nil) else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let erc20Balance):
                    completion(EthServiceResult.success(erc20Balance["0"] as! BigUInt))
                case .failure(let error):
                    completion(EthServiceResult.error(error))
                }
            }
        }
    }

    /// search ETC20Token data for contractaddress
    ///
    /// - Parameters:
    ///   - contractAddress: contractAddress
    ///   - walletAddress: walletAddress
    ///   - completion: result
    static func addERC20TokenToApp(contractAddress: String, walletAddress: String, completion:@escaping (EthServiceResult<TokenModel>) -> Void) {
        var ethAddress: EthereumAddress?
        let cAddress = contractAddress.addHexPrefix()
        ethAddress = EthereumAddress(cAddress)

        guard ethAddress != nil else {
            completion(EthServiceResult.error(CustomTokenError.undefinedError))
            return
        }

        let tokenModel = TokenModel()
        DispatchQueue.global(qos: .userInitiated).async {
            let disGroup = DispatchGroup()

            disGroup.enter()
            CustomERC20TokenService.name(walletAddress: walletAddress, token: cAddress, completion: { (result) in
                switch result {
                case .success(let name):
                    tokenModel.name = name
                case .error(let error):
                    print(error.localizedDescription)
                }
                disGroup.leave()
            })

            disGroup.enter()
            CustomERC20TokenService.symbol(walletAddress: walletAddress, token: cAddress, completion: { (result) in
                switch result {
                case .success(let symbol):
                    tokenModel.symbol = symbol
                case .error(let error):
                    print(error.localizedDescription)
                }
                disGroup.leave()
            })

            disGroup.enter()
            CustomERC20TokenService.decimals(walletAddress: walletAddress, token: cAddress, completion: { (result) in
                switch result {
                case .success(let decimals):
                    tokenModel.decimals = Int(decimals)
                case .error(let error):
                    print(error.localizedDescription)
                }
                disGroup.leave()
            })

            disGroup.notify(queue: .main) {
                guard !tokenModel.name.isEmpty, !tokenModel.symbol.isEmpty else {
                    completion(EthServiceResult.error(CustomTokenError.undefinedError))
                    return
                }
                completion(EthServiceResult.success(tokenModel))
            }
        }
    }
}
