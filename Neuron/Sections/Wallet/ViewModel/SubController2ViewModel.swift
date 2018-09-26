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
    func didGetWalletMessage(walletAddress: String) -> WalletModel {
        let wModel = WalletRealmTool.getCreatWallet(walletAddress: walletAddress)
        return wModel
    }

    /// switch current wallet
    ///
    /// - Parameter walletName: walletName
    func changeCurrentWallet(walletAddress: String) -> WalletModel {
        return WalletRealmTool.getCreatWallet(walletAddress: walletAddress)
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
    func didGetTokenForCurrentwallet(walletAddress: String, completion: @escaping (String?, Error?) -> Void) {
        EthNativeTokenService.getEthNativeTokenBalance(walletAddress: walletAddress) { [weak self] (result) in
            switch result {
            case .Success(let balance):
                let balanceNumber = self?.formatBalanceValue(value: balance)
                completion(balanceNumber, nil)
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
                completion(nil, error)
            }
        }
    }

    func didGetERC20BalanceForCurrentWallet(wAddress: String, ERC20Token: String, completion: @escaping (BigUInt?, Error?) -> Void ) {
        ERC20TokenService.getERC20TokenBalance(walletAddress: wAddress, contractAddress: ERC20Token) { (result) in
            switch result {
            case .Success(let erc20Balance):
                completion(erc20Balance, nil)
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
                completion(nil, error)
            }
        }
    }

    /// get Nervos native chain message
    ///
    /// - Parameter completion:(TokenModel?,Error?)
    func getMateDataForNervos(completion: @escaping (TokenModel?, Error?) -> Void) {
        NervosNativeTokenServiceImp.getNervosNativeTokenMsg { (result) in
            switch result {
            case .Success(let tokenModel):
                completion(tokenModel, nil)
            case .Error(let error):
                completion(nil, error)
            }
        }
    }

    func getNervosNativeTokenBalance(walletAddress: String, completion: @escaping (String?, Error?) -> Void) {
        NervosNativeTokenServiceImp.getNervosNativeTokenBalance(walletAddress: walletAddress) { [weak self] (result) in
            switch result {
            case .Success(let balance):
                let balanceNumber = self?.formatBalanceValue(value: balance)
                completion(balanceNumber, nil)
            case .Error(let error):
                completion(nil, error)
            }
        }
    }

    func formatBalanceValue(value: BigUInt) -> String {
        let format = Web3.Utils.formatToPrecision(value, formattingDecimals: 8, fallbackToScientific: false)!
        let finalValue = Double(format)!
        return finalValue.clean
    }
}
