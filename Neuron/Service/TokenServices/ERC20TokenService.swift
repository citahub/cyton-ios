//
//  ERC20TokenService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/4.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import BigInt
import web3swift

protocol ERC20TokenServiceProtocol {
    static func getERC20TokenBalance(walletAddress:String,contractAddress:String,completion:@escaping(EthServiceResult<BigUInt>)->Void)
    static func addERC20TokenToApp(contractAddress: String,walletAddress:String,completion:@escaping (EthServiceResult<TokenModel>) -> Void)
}


class ERC20TokenService:ERC20TokenServiceProtocol {

    /// getBalance
    ///
    /// - Parameters:
    ///   - walletAddress: wallet public key
    ///   - contractAddress: token address
    ///   - completion: balance result
    static func getERC20TokenBalance(walletAddress: String, contractAddress: String, completion: @escaping (EthServiceResult<BigUInt>) -> Void) {
        let web3 = Web3NetWork.getWeb3()
        let contractETHAddress = EthereumAddress(contractAddress)!
        let coldWalletAddress = EthereumAddress(walletAddress)
        let contract = web3.contract(Web3.Utils.erc20ABI,at:contractETHAddress,abiVersion:2)
        let options = Web3Options.defaultOptions()
        
        DispatchQueue.global().async {
            guard let result = contract?.method("balanceOf", parameters: [coldWalletAddress as AnyObject], options: options)?.call(options: nil) else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let erc20Balance):
                    completion(EthServiceResult.Success(erc20Balance["0"] as! BigUInt))
                    break
                case .failure(let error):
                    completion(EthServiceResult.Error(error))
                    break
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
    static func addERC20TokenToApp(contractAddress: String,walletAddress:String,completion:@escaping (EthServiceResult<TokenModel>) -> Void) {
        
        var ethAddress:EthereumAddress?
        var cAddress:String = ""
        if contractAddress.hasPrefix("0x") {
            cAddress = contractAddress
        }else{
            cAddress = "0x" + contractAddress
        }
        ethAddress = EthereumAddress(cAddress)

        
        guard ethAddress != nil else {
            completion(EthServiceResult.Error(CustomTokenError.undefinedError))
            return
        }
        
        let tokenModel = TokenModel()
        DispatchQueue.global(qos: .userInitiated).async {
            
            let disGroup = DispatchGroup()
            
            disGroup.enter()
            CustomERC20TokenService.name(walletAddress: walletAddress, token: cAddress, completion: { (result) in
                switch result{
                case .Success(let name):
                    tokenModel.name = name
                    break
                case .Error(let error):
                    print(error.localizedDescription)
                    break
                }
                disGroup.leave()
            })
            
            disGroup.enter()
            CustomERC20TokenService.symbol(walletAddress: walletAddress, token: cAddress, completion: { (result) in
                switch result{
                case .Success(let symbol):
                    tokenModel.symbol = symbol
                    break
                case .Error(let error):
                    print(error.localizedDescription)
                    break
                }
                disGroup.leave()
            })
            
            disGroup.enter()
            CustomERC20TokenService.decimals(walletAddress: walletAddress, token: cAddress, completion: { (result) in
                switch result{
                case .Success(let decimals):
                    tokenModel.decimals = Int(Web3.Utils.formatToPrecision(decimals)!) ?? 6
                    break
                case .Error(let error):
                    print(error.localizedDescription)
                    break
                }
                disGroup.leave()
            })
            
            disGroup.notify(queue: .main){
                guard !tokenModel.name.isEmpty,!tokenModel.symbol.isEmpty else {
                    completion(EthServiceResult.Error(CustomTokenError.undefinedError))
                    return
                }
                completion(EthServiceResult.Success(tokenModel))
            }
        }
    }
    
    
}


