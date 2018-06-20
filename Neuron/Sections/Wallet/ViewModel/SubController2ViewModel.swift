//
//  SubController2ViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/19.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SubController2ViewModel: NSObject {
    
    /// 获取当前钱包的数据
    func didGetWalletMessage(walletAddress:String) -> WalletModel {
        let wModel = WalletRealmTool.getCreatWallet(walletAddress: walletAddress)
        return wModel
    }
    
    
    /// 切换当前显示的钱包
    ///
    /// - Parameter walletName: walletName
    func changeCurrentWallet(walletAddress:String) -> WalletModel {
        return WalletRealmTool.getCreatWallet(walletAddress:walletAddress)
    }
    
    
    /// 获取当前app的整个model
    ///
    /// - Returns: appmodel
    func getCurrentModel() -> AppModel {
        return WalletRealmTool.getCurrentAppmodel()
    }
    
}
