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

protocol ImportWalletViewModelDelegate: class {
    func didPopToRootView()
}

enum ImportWalletType {
    case keystoreType
    case mnemonicType
    case privateKeyType
}

class ImportWalletViewModel: NSObject {

    weak var delegate: ImportWalletViewModelDelegate?
    var walletModel = WalletModel()
    var importType = ImportWalletType.keystoreType

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
    func importKeystoreWallet(keyStore: String, password: String, name: String) {
        if keyStore.isEmpty {NeuLoad.showToast(text: "请输入keystore文本");return}
        if name.isEmpty {NeuLoad.showToast(text: "钱包名字不能为空");return}
        if name.count > 15 {
            NeuLoad.showToast(text: "钱包名字不能超过15个字符")
            return
        }
        if password.isEmpty {NeuLoad.showToast(text: "解锁密码不能为空");return}
        if !WalletTools.checkWalletName(name: name) {NeuLoad.showToast(text: "钱包名字重复");return}
        NeuLoad.showHUD(text: "导入钱包中")
        walletModel.name = name
        walletModel.MD5screatPassword = CryptoTool.changeMD5(password: password)
        let importType = ImportType.keyStore(json: keyStore, password: password)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                self.walletModel.address = account.address.eip55String
                self.exportPirvateKey(account: account, password: password)
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        }
    }

    /// get privateKey
    func exportPirvateKey(account: Account, password: String) {
        let privateKeyResult = WalletTools.exportPrivateKey(account: account, password: password)
        switch privateKeyResult {
        case .succeed(result: let privateKey):
            walletModel.encryptPrivateKey = CryptoTool.Endcode_AES_ECB(strToEncode: privateKey!, key: password)
            didSaveWalletToRealm()
        case .failed(_, let errorMsg):
            NeuLoad.showToast(text: errorMsg)
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
        let appModel = WalletRealmTool.getCurrentAppModel()
        let walletCount = appModel.wallets.count
        let iconImage = GitHubIdenticon().icon(from: walletModel.address.lowercased(), size: CGSize(width: 60, height: 60))
        walletModel.iconData = iconImage!.pngData()!
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
            appModel.wallets.append(walletModel)
            WalletRealmTool.addObject(appModel: appModel)
        }
        NeuLoad.hidHUD()
        NeuLoad.showToast(text: "导入成功")
        if walletCount == 0 {
            NotificationCenter.default.post(name: .allWalletsDeleted, object: self)
        }

        NotificationCenter.default.post(name: .createWalletSuccess, object: self, userInfo: ["post": walletModel.address])
        delegate?.didPopToRootView()
    }

    /// import wallet with mnemonic
    ///
    /// - Parameters:
    ///   - mnemonic: mnemonic
    ///   - password: password
    ///   - devirationPath: devirationPath
    ///   - name: walletname
    func importWalletWithMnemonic(mnemonic: String, password: String, confirmPassword: String, devirationPath: String, name: String) {
        if mnemonic.isEmpty {NeuLoad.showToast(text: "请输入助记词");return}
        if name.isEmpty {NeuLoad.showToast(text: "钱包名字不能为空");return}
        if name.count > 15 {
            NeuLoad.showToast(text: "钱包名字不能超过15个字符")
            return
        }
        if password != confirmPassword {NeuLoad.showToast(text: "两次密码输入不一致");return}
        if !PasswordValidator.isValid(password: password) {return}
        if !WalletTools.checkWalletName(name: name) {NeuLoad.showToast(text: "钱包名字重复");return}
        NeuLoad.showHUD(text: "导入钱包中")
        walletModel.name = name
        walletModel.MD5screatPassword = CryptoTool.changeMD5(password: password)
        let importType = ImportType.mnemonic(mnemonic: mnemonic, password: password, derivationPath: devirationPath)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
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
    func importPrivateWallet(privateKey: String, password: String, confirmPassword: String, name: String) {
        if privateKey.isEmpty {NeuLoad.showToast(text: "请输入私钥");return}
        if name.isEmpty {NeuLoad.showToast(text: "钱包名字不能为空");return}
        if name.count > 15 {
            NeuLoad.showToast(text: "钱包名字不能超过15个字符")
            return
        }
        if password != confirmPassword {NeuLoad.showToast(text: "两次密码输入不一致");return}
        if !PasswordValidator.isValid(password: password) {return}
        if !WalletTools.checkWalletName(name: name) {NeuLoad.showToast(text: "钱包名字重复");return}
        NeuLoad.showHUD(text: "导入钱包中")
        walletModel.name = name
        walletModel.MD5screatPassword = CryptoTool.changeMD5(password: password)
        walletModel.encryptPrivateKey = CryptoTool.Endcode_AES_ECB(strToEncode: privateKey, key: password)
        let importType = ImportType.privateKey(privateKey: privateKey, password: password)
        WalletTools.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                self.walletModel.address = account.address.eip55String
                self.didSaveWalletToRealm()
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        }
    }
}
