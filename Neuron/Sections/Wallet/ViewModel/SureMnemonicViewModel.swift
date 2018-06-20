//
//  SureMnemonicViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/15.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrustKeystore
import RealmSwift
import IGIdenticon

protocol SureMnemonicViewModelDelegate {
    func doPush()
}


class SureMnemonicViewModel: NSObject {
    
    var walletName = ""
    var walletPassword = ""
    var walletKeyStore = ""
    var walletMnemonic = ""
    var walletAddress = ""
    var walletPrivateKey = ""
    
    var delegate:SureMnemonicViewModelDelegate?
    typealias SureMnemonicViewModelBlcol = (_ str:String) -> Void
    var walletModel = WalletModel()
    
    // 验证助记词
    public func compareMnemonic(original: String, current: String) -> Bool {
        if original == current {
            return true
        }else{
            NeuLoad.showToast(text: "助记词验证失败")
            return true
        }
    }
    
    //导入钱包
    public func didImportWalletToRealm() {
        // 通过助记词导入钱包
        NeuLoad.showHUD(text:"钱包创建中...")
        WalletTools.importMnemonicAsync(mnemonic: walletModel.mnemonic, password: walletModel.password, devirationPath: WalletTools.defaultDerivationPath, completion: { (result) in
            switch result {
            case .succeed(let account):
                print(account)
                self.walletName = self.walletModel.name
                self.walletAddress = account.address.eip55String
                self.exportKeystoreAndPirvateKey(account: account)
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        })
    }
    
    //导出私钥 地址 keystore
    func exportKeystoreAndPirvateKey(account:Account) {
        let privateKeyResult = WalletTools.exportPrivateKey(account: account, password: walletModel.password)
        switch privateKeyResult {
        case .succeed(result: let privateKey):
            print(privateKey!)
            self.walletPrivateKey = privateKey!
            self.exportKeystoreStr(privateKey: privateKey!)
            break
        case .failed(let errorStr, let errorMsg):
            NeuLoad.showToast(text:errorMsg)
            print(errorStr)
            break
        }
    }
    
    //生成keystore
    func exportKeystoreStr(privateKey:String) {
        let kS = WalletTools.convertPrivateKeyToJSON(hexPrivateKey: privateKey, password: walletModel.password)
        switch kS {
        case .succeed(let result):
            self.walletKeyStore = result
            print("keystore:" + result)
            self.saveWallet()
            break
        case .failed(let error,let errorMessage):
            NeuLoad.showToast(text:errorMessage)
            print(error)
            break
        }
    }
    
    func saveWallet() {
        let realm = try! Realm()
        let appModel = AppModel()
        walletModel.address = walletAddress
        walletModel.privateKey = walletPrivateKey
        walletModel.keyStore =  walletKeyStore
        let gitIcon = GitHubIdenticon.init()
        let iconImage = gitIcon.icon(from: walletModel.name, size: CGSize(width: 60, height: 60))
        let imageData = UIImagePNGRepresentation(iconImage!)
        walletModel.iconData = imageData
        appModel.wallets.append(walletModel)
        appModel.currentWallet = walletModel
        try! realm.write {
            NeuLoad.showToast(text: "创建成功")
            realm.add(appModel)
            changeTabbar()
            delegate?.doPush()
            didPostCreatSuccessNotify()
        }
    }
    
    func didPostCreatSuccessNotify()  {
        //发出创建钱包成功的通知，同时吧钱包name传过去
        NotificationCenter.default.post(name:.creatWalletSuccess, object: self, userInfo: ["post":walletModel.address])
    }
    
    //如果创建成功钱包 就去执行mainviewcontroller里的更换tabbar的操作
    func changeTabbar() {
        NotificationCenter.default.post(name: .changeTabbr, object: self)
    }
    
}
