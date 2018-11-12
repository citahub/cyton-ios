//
//  MnemonicViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import EthereumAddress
import IGIdenticon

class MnemonicViewController: UITableViewController, QRCodeViewControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var mnemonicTextView: RSKPlaceholderTextView!

    var selectFormatId = "0"
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    var mnemonic: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        mnemonicTextView.delegate = self
    }

    @IBAction func nameChanged(_ sender: UITextField) {
        name = sender.text
        judgeImportButtonEnabled()
    }

    @IBAction func passwordChanged(_ sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        password = sender.text
        judgeImportButtonEnabled()
    }

    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        confirmPassword = sender.text
        judgeImportButtonEnabled()
    }

    func didGetTextViewText(text: String) {
        mnemonic = text
        judgeImportButtonEnabled()
    }

    func didBackQRCodeMessage(codeResult: String) {
        mnemonic = codeResult
        mnemonicTextView.text = codeResult
        judgeImportButtonEnabled()
    }

    func judgeImportButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty || mnemonic!.isEmpty {
            importButton.backgroundColor = ColorFromString(hex: "#E9EBF0")
            importButton.isEnabled = false
        } else {
            importButton.backgroundColor = ColorFromString(hex: "#456CFF")
            importButton.isEnabled = true
        }
    }

   @IBAction func didClickQRBtn() {
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        self.navigationController?.pushViewController(qrCodeViewController, animated: true)
    }

    @IBAction func importWallet(_ sender: UIButton) {
        importWalletWithMnemonic(mnemonic: mnemonic!, password: password!, confirmPassword: confirmPassword!, name: name!)
    }

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
        let walletModel = WalletModel()
        walletModel.name = name
        Toast.showHUD(text: "导入钱包中")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importMnemonic(mnemonic: mnemonic, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm(with: walletModel)
                    SensorsAnalytics.Track.importWallet(type: .mnemonic, address: walletModel.address)
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                    SensorsAnalytics.Track.importWallet(type: .mnemonic, address: nil)
                }
            }
        }
    }

    private func saveWalletToRealm(with walletModel: WalletModel) {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let result: [WalletModel] = appModel.wallets.filter { (wallet) -> Bool in
            return wallet.address == walletModel.address
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
            SensorsAnalytics.Track.importWallet(type: .keystore, address: walletModel.address)
            if isFirstWallet {
                NotificationCenter.default.post(name: .firstWalletCreated, object: nil)
            }
            NotificationCenter.default.post(name: .createWalletSuccess, object: nil, userInfo: ["address": walletModel.address])
            navigationController?.popToRootViewController(animated: true)
        } catch {
            Toast.showToast(text: error.localizedDescription)
        }
    }
}

extension MnemonicViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        mnemonic = textView.text
        judgeImportButtonEnabled()
    }
}
