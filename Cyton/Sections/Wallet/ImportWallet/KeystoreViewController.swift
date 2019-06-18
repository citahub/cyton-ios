//
//  KeystoreViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import web3swift
import RealmSwift

class KeystoreViewController: UITableViewController, QRCodeViewControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var keyStoreTextView: RSKPlaceholderTextView!
    var name: String? = ""
    var password: String? = ""
    var keystore: String? = ""

    @IBOutlet weak var titleContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var walletNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Wallet.Import.inputKeystoreWarning".localized()
        keyStoreTextView.placeholder = "Wallet.Import.inputKeystore".localized() as NSString
        walletNameTextField.placeholder = "Wallet.Import.inputWalletName".localized()
        passwordTextField.placeholder = "Wallet.Import.inputWalletPassword".localized()
        importButton.setTitle("Wallet.Import.import".localized(), for: .normal)

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
            Toast.showToast(text: "Wallet.Import.inputKeystore".localized())
            return
        }

        if case .invalid(let reason) = WalletNameValidator.validate(walletName: name) {
            Toast.showToast(text: reason)
            return
        }

        if password.isEmpty {
            Toast.showToast(text: "Wallet.Import.emptyKeystorePassword".localized())
            return
        }
        let walletModel = WalletModel()
        walletModel.name = name
        Toast.showHUD(text: "Wallet.Import.loading".localized())
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importKeystore(keystore, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm(with: walletModel)
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
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
            Toast.showToast(text: "Wallet.Import.walletAlreadyExists".localized())
            return
        }

        do {
            let realm = try! Realm()
            try realm.write {
                appModel.currentWallet = walletModel
                appModel.wallets.append(walletModel)
                realm.add(appModel)
            }
            DefaultTokenAndChain().addDefaultTokenToWallet(wallet: walletModel)
            Toast.showToast(text: "Wallet.Import.success".localized())
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
