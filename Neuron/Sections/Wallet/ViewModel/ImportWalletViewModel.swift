//
//  ImportWalletViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/20.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrustKeystore
import struct TrustCore.EthereumAddress
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
    ///   - keystore: keystore
    ///   - password: password
    ///   - name: walletName
    func importKeystoreWallet(keystore: String, password: String, name: String) {
        if keystore.isEmpty {
            Toast.showToast(text: "请输入keystore文本")
            return
        }
        if name.isEmpty {
            Toast.showToast(text: "钱包名字不能为空")
            return
        }
        if name.count > 15 {
            Toast.showToast(text: "钱包名字不能超过15个字符")
            return
        }
        if !WalletTool.checkWalletName(name: name) {
            Toast.showToast(text: "钱包名字重复")
            return
        }
        if password.isEmpty {
            Toast.showToast(text: "解锁密码不能为空")
            return
        }
        Toast.showHUD(text: "导入钱包中")
        walletModel.name = name
        let importType = ImportType.keystore(keystore: keystore, password: password)
        WalletTool.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                self.walletModel.address = EthereumAddress(data: account.address.data)!.eip55String
                self.didSaveWalletToRealm()
            case .failed(_, let errorMessage):
                Toast.showToast(text: errorMessage)
            }
            Toast.hideHUD()
        }
    }

    /// save wallet
    func didSaveWalletToRealm() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let isFirstWallet = appModel.wallets.count == 0
        let iconImage = GitHubIdenticon().icon(from: walletModel.address.lowercased(), size: CGSize(width: 60, height: 60))
        walletModel.iconData = iconImage!.pngData()!
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
            appModel.wallets.append(walletModel)
            WalletRealmTool.addObject(appModel: appModel)
        }
        Toast.showToast(text: "导入成功")
        if isFirstWallet {
            NotificationCenter.default.post(name: .firstWalletCreated, object: nil)
        }
        NotificationCenter.default.post(name: .createWalletSuccess, object: nil, userInfo: ["address": walletModel.address])
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
        if mnemonic.isEmpty {Toast.showToast(text: "请输入助记词");return}
        if name.isEmpty {Toast.showToast(text: "钱包名字不能为空");return}
        if name.count > 15 {
            Toast.showToast(text: "钱包名字不能超过15个字符")
            return
        }
        if password != confirmPassword {Toast.showToast(text: "两次密码输入不一致");return}
        if !PasswordValidator.isValid(password: password) {return}
        if !WalletTool.checkWalletName(name: name) {Toast.showToast(text: "钱包名字重复");return}
        Toast.showHUD(text: "导入钱包中")
        walletModel.name = name
        let importType = ImportType.mnemonic(mnemonic: mnemonic, password: password, derivationPath: devirationPath)
        WalletTool.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                self.walletModel.address = EthereumAddress(data: account.address.data)!.eip55String
                self.didSaveWalletToRealm()
            case .failed(_, let errorMessage):
                Toast.showToast(text: errorMessage)
            }
            Toast.hideHUD()
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
        if privateKey.isEmpty {Toast.showToast(text: "请输入私钥");return}
        if name.isEmpty {Toast.showToast(text: "钱包名字不能为空");return}
        if name.count > 15 {
            Toast.showToast(text: "钱包名字不能超过15个字符")
            return
        }
        if password != confirmPassword {Toast.showToast(text: "两次密码输入不一致");return}
        if !PasswordValidator.isValid(password: password) {return}
        if !WalletTool.checkWalletName(name: name) {Toast.showToast(text: "钱包名字重复");return}
        Toast.showHUD(text: "导入钱包中")
        walletModel.name = name
        let importType = ImportType.privateKey(privateKey: privateKey, password: password)
        WalletTool.importWallet(with: importType) { (result) in
            switch result {
            case .succeed(let account):
                self.walletModel.address = EthereumAddress(data: account.address.data)!.eip55String
                self.didSaveWalletToRealm()
            case .failed(_, let errorMessage):
                Toast.showToast(text: errorMessage)
            }
            Toast.hideHUD()
        }
    }
}
