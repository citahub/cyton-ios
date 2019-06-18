//
//  PrivatekeyViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import web3swift
import RealmSwift

class PrivatekeyViewController: UITableViewController, QRCodeViewControllerDelegate, EnterBackOverlayPresentable {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var privatekeyTextView: RSKPlaceholderTextView!
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    var privateKey: String? = ""

    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var walletNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var passwordDescLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.text = "Wallet.Import.inputPrivatekeyWarning".localized()
        privatekeyTextView.placeholder = "Wallet.Import.inputPrivatekey".localized() as NSString
        walletNameTextField.placeholder = "Wallet.Import.inputWalletName".localized()
        passwordTextField.placeholder = "Wallet.Import.setPassword".localized()
        rePasswordTextField.placeholder = "Wallet.Import.repeatPassword".localized()
        passwordDescLabel.text = "Wallet.Import.setPasswordDesc".localized()
        importButton.setTitle("Wallet.Import.import".localized(), for: .normal)

        privatekeyTextView.delegate = self
        setupEnterBackOverlay()
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
        privateKey = text
        judgeImportButtonEnabled()
    }

    func didBackQRCodeMessage(codeResult: String) {
        privateKey = codeResult
        privatekeyTextView.text = codeResult
        judgeImportButtonEnabled()
    }

    func judgeImportButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty || privateKey!.isEmpty {
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
        importPrivateWallet(privateKey: privateKey!, password: password!, confirmPassword: confirmPassword!, name: name!)
    }

    func importPrivateWallet(privateKey: String, password: String, confirmPassword: String, name: String) {
        if privateKey.isEmpty {
            Toast.showToast(text: "Wallet.Import.inputPrivatekey".localized())
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
            Toast.showToast(text: "Wallet.Import.inconsistentPasswords".localized())
            return
        }
        let walletModel = WalletModel()
        walletModel.name = name
        Toast.showHUD(text: "Wallet.Import.loading".localized())
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importPrivateKey(privateKey: privateKey, password: password)
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

extension PrivatekeyViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        privateKey = textView.text
        judgeImportButtonEnabled()
    }
}
