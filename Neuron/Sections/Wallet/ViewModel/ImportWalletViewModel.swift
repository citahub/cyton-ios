//
//  ImportWalletViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/20.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
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
    var isUseQRCode = false

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

        if case .invalid(let reason) = WalletNameValidator.validate(walletName: name) {
            Toast.showToast(text: reason)
            return
        }
        if password.isEmpty {
            Toast.showToast(text: "解锁密码不能为空")
            return
        }

        walletModel.name = name
        Toast.showHUD(text: "导入钱包中")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importKeystore(keystore, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm()
                    SensorsAnalytics.Track.importWallet(type: .keystore, address: self.walletModel.address)
                    if self.isUseQRCode {
                        SensorsAnalytics.Track.scanQRCode(scanType: .keystore, scanResult: true)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                    SensorsAnalytics.Track.importWallet(type: .keystore, address: nil)
                    if self.isUseQRCode {
                        SensorsAnalytics.Track.scanQRCode(scanType: .keystore, scanResult: false)
                    }
                }
            }
        }
    }

    private func saveWalletToRealm() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let result: [WalletModel] = appModel.wallets.filter { (wallet) -> Bool in
            return wallet.address == self.walletModel.address
        }
        if result.count >= 1 {
            Toast.showToast(text: "已存在该钱包")
            return
        }

        let isFirstWallet = appModel.wallets.count == 0
        let iconImage = GitHubIdenticon().icon(from: walletModel.address.lowercased(), size: CGSize(width: 60, height: 60))
        walletModel.iconData = iconImage!.pngData()!
        do {
            try WalletRealmTool.realm.write {
                appModel.currentWallet = walletModel
                appModel.wallets.append(walletModel)
                WalletRealmTool.addObject(appModel: appModel)
            }
            Toast.showToast(text: "导入成功")
            SensorsAnalytics.Track.importWallet(type: .keystore, address: self.walletModel.address)
            if self.isUseQRCode {
                SensorsAnalytics.Track.scanQRCode(scanType: .keystore, scanResult: true)
            }
            if isFirstWallet {
                NotificationCenter.default.post(name: .firstWalletCreated, object: nil)
            }
            NotificationCenter.default.post(name: .createWalletSuccess, object: nil, userInfo: ["address": walletModel.address])
            delegate?.didPopToRootView()
        } catch {
            Toast.showToast(text: error.localizedDescription)
        }
    }

    /// import wallet with mnemonic
    ///
    /// - Parameters:
    ///   - mnemonic: mnemonic
    ///   - password: password
    ///   - devirationPath: devirationPath
    ///   - name: walletname
    func importWalletWithMnemonic(mnemonic: String, password: String, confirmPassword: String, devirationPath: String = "m/44'/60'/0'/0/0", name: String) {
        if mnemonic.isEmpty {
            Toast.showToast(text: "请输入助记词")
            return
        }

        if case .invalid(let reason) = WalletNameValidator.validate(walletName: name) {
            Toast.showToast(text: reason)
            return
        }

        if case .invalid(let reason) = PasswordValidator.validate(password: password) {
            Toast.showToast(text: reason)
            return
        }
        if password != confirmPassword {
            Toast.showToast(text: "两次密码输入不一致")
            return
        }

        walletModel.name = name
        Toast.showHUD(text: "导入钱包中")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importMnemonic(mnemonic: mnemonic, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm()
                    SensorsAnalytics.Track.importWallet(type: .mnemonic, address: self.walletModel.address)
                    if self.isUseQRCode {
                        SensorsAnalytics.Track.scanQRCode(scanType: .mnemonic, scanResult: true)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                    SensorsAnalytics.Track.importWallet(type: .mnemonic, address: nil)
                    if self.isUseQRCode {
                        SensorsAnalytics.Track.scanQRCode(scanType: .mnemonic, scanResult: false)
                    }
                }
            }
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
        if privateKey.isEmpty {
            Toast.showToast(text: "请输入私钥")
            return
        }
        if case .invalid(let reason) = WalletNameValidator.validate(walletName: name) {
            Toast.showToast(text: reason)
            return
        }
        if case .invalid(let reason) = PasswordValidator.validate(password: password) {
            Toast.showToast(text: reason)
            return
        }
        if password != confirmPassword {
            Toast.showToast(text: "两次密码输入不一致")
            return
        }

        walletModel.name = name
        Toast.showHUD(text: "导入钱包中")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importPrivateKey(privateKey: privateKey, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm()
                    SensorsAnalytics.Track.importWallet(type: .privateKey, address: self.walletModel.address)
                    if self.isUseQRCode {
                        SensorsAnalytics.Track.scanQRCode(scanType: .privateKey, scanResult: true)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                    SensorsAnalytics.Track.importWallet(type: .privateKey, address: nil)
                    if self.isUseQRCode {
                        SensorsAnalytics.Track.scanQRCode(scanType: .privateKey, scanResult: false)
                    }
                }
            }
        }
    }
}
