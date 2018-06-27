//
//  ImportWalletViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/20.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrustKeystore
import IGIdenticon

protocol ImportWalletViewModelDelegate {
    func didPopToRootView()
}

enum importWalletType {
    case keystoreType
    case mnemonicType
    case privateKeyType
}

class ImportWalletViewModel: NSObject {
    
    var delegate:ImportWalletViewModelDelegate?
    var walletModel = WalletModel()
    var importType = importWalletType.keystoreType
    
    
    /// if change the way to import wallet the walletModel should be empy
    func changeImportWay() {
        walletModel = WalletModel()
    }
    
    
    /// import keyStore wallet
    /// if import wallet way is keystore or privatekey,there is no mnemonic
    /// - Parameters:
    ///   - keyStore: keyStore
    ///   - password: password
    ///   - name: walletName
    func importKeyStoreWallet(keyStore:String,password:String,name:String) {
        if keyStore.isEmpty {NeuLoad.showToast(text: "请输入keystore文本");return}
        if name.isEmpty {NeuLoad.showToast(text: "钱包名字不能为空");return}
        if password.isEmpty {NeuLoad.showToast(text: "解锁密码不能为空");return}
        if !WalletTools.checkWalletName(name: name) {NeuLoad.showToast(text: "钱包名字重复");return}
        NeuLoad.showHUD(text: "导入钱包中")
        walletModel.name = name
        walletModel.MD5screatPassword = CryptTools.changeMD5(password: password)
        let importType = ImportType.keyStore(json: keyStore, password: password)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                print(account)
                self.walletModel.address = account.address.eip55String
                self.exportPirvateKey(account: account, password: password)
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        }
    }
    
    
    /// get privateKey
    func exportPirvateKey(account:Account,password:String) {
        let privateKeyResult = WalletTools.exportPrivateKey(account: account, password: password)
        switch privateKeyResult {
        case .succeed(result: let privateKey):
            print(privateKey!)
            walletModel.encryptPrivateKey = CryptTools.Endcode_AES_ECB(strToEncode: privateKey!, key: password)
            didSaveWalletToRealm()
            break
        case .failed(_, let errorMsg):
            NeuLoad.showToast(text:errorMsg)
            break
        }
    }
    
    
    /// getkeystore JSONString
    ///
    /// - Parameters:
    ///   - privateKey: hexPrivateKey
    ///   - password: password
//    func getKeystore(privateKey:String,password:String) {
//        let keystoreReuslt = WalletTools.convertPrivateKeyToJSON(hexPrivateKey: privateKey, password: password)
//        switch keystoreReuslt {
//        case .succeed(result:let keystoreStr):
//            walletModel.keyStore = keystoreStr
//            switch importType {
//            case .keystoreType:
//                break
//            case .mnemonicType:
//                didSaveWalletToRealm()
//                break
//            case .privateKeyType:
//                didSaveWalletToRealm()
//                break
//            }
//            break
//        case .failed(_, let errorMessage):
//            NeuLoad.showToast(text: errorMessage)
//            break
//        }
//        
//    }
    
    /// save wallet
    func didSaveWalletToRealm() {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        let walletCount = appModel.wallets.count
        let gitIcon = GitHubIdenticon.init()
        let iconImage = gitIcon.icon(from: walletModel.name, size: CGSize(width: 60, height: 60))
        let imageData = UIImagePNGRepresentation(iconImage!)
        walletModel.iconData = imageData
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
            appModel.wallets.append(walletModel)
            WalletRealmTool.addObject(appModel: appModel)
        }
        NeuLoad.hidHUD()
        NeuLoad.showToast(text: "导入成功")
        if walletCount == 0 {
            changeTabbar()
        }
        didPostCreatSuccessNotify()
        delegate?.didPopToRootView()
    }
    
    
    /// import wallet with mnemonic
    ///
    /// - Parameters:
    ///   - mnemonic: mnemonic
    ///   - password: password
    ///   - devirationPath: devirationPath
    ///   - name: walletname
    func importWalletWithMnemonic(mnemonic:String,password:String,confirmPassword:String,devirationPath:String,name:String) {
        if mnemonic.isEmpty {NeuLoad.showToast(text: "请输入助记词");return}
        if name.isEmpty {NeuLoad.showToast(text: "钱包名字不能为空");return}
        if password != confirmPassword {NeuLoad.showToast(text: "两次密码输入不一致");return}
        if !isThePasswordMeetCondition(password: password) {return}
        if !WalletTools.checkWalletName(name: name) {NeuLoad.showToast(text: "钱包名字重复");return}
        NeuLoad.showHUD(text: "导入钱包中")
        walletModel.name = name
        let importType = ImportType.mnemonic(mnemonic: mnemonic, password: password, derivationPath: devirationPath)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                print(account)
                self.walletModel.address = account.address.eip55String
                self.exportPirvateKey(account: account, password: password)
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        }
    }
    
    
    /// import wallet with privatekey
    ///
    /// - Parameters:
    ///   - privateKey: privateKey
    ///   - password: password
    ///   - confirmPassword: confirmPassword
    ///   - name: name
    func importPrivateWallet(privateKey:String,password:String,confirmPassword:String,name:String) {
        if privateKey.isEmpty {NeuLoad.showToast(text: "请输入私钥");return}
        if name.isEmpty {NeuLoad.showToast(text: "钱包名字不能为空");return}
        if password != confirmPassword {NeuLoad.showToast(text: "两次密码输入不一致");return}
        if !isThePasswordMeetCondition(password: password) {return}
        if !WalletTools.checkWalletName(name: name) {NeuLoad.showToast(text: "钱包名字重复");return}
        NeuLoad.showHUD(text: "导入钱包中")
        walletModel.name = name
        walletModel.encryptPrivateKey = CryptTools.Endcode_AES_ECB(strToEncode: privateKey, key: password)
        let importType = ImportType.privateKey(privateKey: privateKey, password: password)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                print(account)
                self.walletModel.address = account.address.eip55String
                self.didSaveWalletToRealm()
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        }
    }
    
    
    private func didPostCreatSuccessNotify()  {
        //import wallet success send notify
        NotificationCenter.default.post(name:.creatWalletSuccess, object: self, userInfo: ["post":walletModel.address])
    }
    private func changeTabbar() {
        NotificationCenter.default.post(name: .changeTabbr, object: self)
    }
    
}
