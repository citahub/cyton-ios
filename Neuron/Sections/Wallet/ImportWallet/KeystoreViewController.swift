//
//  KeystoreViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import EthereumAddress
import IGIdenticon
import RealmSwift

class KeystoreViewController: UITableViewController, QRCodeViewControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var keyStoreTextView: RSKPlaceholderTextView!
    var name: String? = ""
    var password: String? = ""
    var keystore: String? = ""

    @IBOutlet weak var titleContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        keyStoreTextView.delegate = self

        let titleHeight = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: titleLabel.bounds.size.width, height: 100), limitedToNumberOfLines: 0).size.height
        titleContentView.frame = CGRect(origin: titleContentView.frame.origin, size: CGSize(width: titleContentView.bounds.size.width, height: max(titleHeight + 12, 35.0)))
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

    func didBackQRCodeMessage(codeResult: String) {
        keystore = codeResult
        keyStoreTextView.text = codeResult
        judgeImportButtonEnabled()
    }

    func judgeImportButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean!.isEmpty || password!.isEmpty || keystore!.isEmpty {
            importButton.backgroundColor = UIColor(hex: "#E9EBF0")
            importButton.isEnabled = false
        } else {
            importButton.backgroundColor = UIColor(hex: "#456CFF")
            importButton.isEnabled = true
        }
    }

    @IBAction func didClickQRBtn() {
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        self.navigationController?.pushViewController(qrCodeViewController, animated: true)
    }

    @IBAction func importWallet(_ sender: UIButton) {
        importKeystoreWallet(keystore: keystore!, password: password!, name: name!)
    }

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
        let walletModel = WalletModel()
        walletModel.name = name
        Toast.showHUD(text: "导入钱包中")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importKeystore(keystore, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm(with: walletModel)
                    SensorsAnalytics.Track.importWallet(type: .keystore, address: walletModel.address)
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                    SensorsAnalytics.Track.importWallet(type: .keystore, address: nil)
                }
            }
        }
    }

    private func saveWalletToRealm(with walletModel: WalletModel) {
        let appModel = AppModel.current
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
            let realm = try! Realm()
            try realm.write {
                appModel.currentWallet = walletModel
                appModel.wallets.append(walletModel)
                realm.add(appModel)
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

extension KeystoreViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        keystore = textView.text
        judgeImportButtonEnabled()
    }
}
