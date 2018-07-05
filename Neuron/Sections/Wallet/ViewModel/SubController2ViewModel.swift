//
//  SubController2ViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/19.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class SubController2ViewModel: NSObject {
    
    /// get current wallet data
    func didGetWalletMessage(walletAddress:String) -> WalletModel {
        let wModel = WalletRealmTool.getCreatWallet(walletAddress: walletAddress)
        return wModel
    }
    
    
    /// switch current wallet
    ///
    /// - Parameter walletName: walletName
    func changeCurrentWallet(walletAddress:String) -> WalletModel {
        return WalletRealmTool.getCreatWallet(walletAddress:walletAddress)
    }
    
    
    /// get Appmodel
    ///
    /// - Returns: appmodel
    func getCurrentModel() -> AppModel {
        return WalletRealmTool.getCurrentAppmodel()
    }
    
    
    /// get eth balance
    ///
    /// - Parameter walletAddress: wallet Address
    /// - Returns: balance
    func didGetTokenForCurrentwallet(walletAddress:String,completion: @escaping (String?, Error?) -> Void){
        EthNativeTokenService.getEthNativeTokenBalance(walletAddress: walletAddress) { (result) in
            switch result{
            case .Success(let balance):
                let ethBalance = Web3.Utils.formatToEthereumUnits(balance,
                                                                  toUnits: .eth,
                                                                  decimals: 6,
                                                                  fallbackToScientific: false)
                let balanceNumber = Float(ethBalance!)
                completion(String(balanceNumber!),nil)
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
                completion(nil,error)
            }
        }
    }
    
    func didGetERC20BalanceForCurrentWallet(wAddress:String,ERC20Token:String,completion: @escaping (BigUInt?,Error?) ->Void ) {
        ERC20TokenService.getERC20TokenBalance(walletAddress: wAddress, contractAddress: ERC20Token) { (result) in
            
            switch result{
            case .Success(let erc20Balance):
                completion(erc20Balance,nil)
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
                completion(nil,error)
            }
            
            
        }
        
        
        
    }
    
    
}
