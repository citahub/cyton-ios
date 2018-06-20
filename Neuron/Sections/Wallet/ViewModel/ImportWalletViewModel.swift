//
//  ImportWalletViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/20.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ImportWalletViewModel: NSObject {
    
    
    /// import keyStore wallet
    ///
    /// - Parameters:
    ///   - keyStore: keyStore
    ///   - password: password
    ///   - name: walletName
    func importKeyStoreWallet(keyStore:String,password:String,name:String) {
        NeuLoad.showToast(text: "导入钱包中")
        let importType = ImportType.keyStore(json: keyStore, password: password)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                print(account)
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.dismissToast()
        }
    }
    
    
    
    
}
