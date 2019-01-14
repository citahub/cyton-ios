//
//  CreatWalletController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class CreateWalletController: UITableViewController {
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var passwordWarningLabel: UILabel!
    @IBOutlet private weak var passwordDescLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var rePasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Create.createWallet".localized()
        passwordWarningLabel.text = "Wallet.Create.passwordWarning".localized()
        nameTextField.placeholder = "Wallet.Create.walletName".localized()
        passwordTextField.placeholder = "Wallet.Create.setPassword".localized()
        rePasswordTextField.placeholder = "Wallet.Create.rePassword".localized()
        nextButton.setTitle("Common.next".localized(), for: .normal)
        passwordDescLabel.text = "Wallet.Create.passwordDesc".localized()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func walletNameChanged(_ sender: UITextField) {
        name = sender.text
        jugeNextButtonEnabled()
    }

    @IBAction func passwordChanged(_ sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        password = sender.text
        jugeNextButtonEnabled()
    }

    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        confirmPassword = sender.text
        jugeNextButtonEnabled()
    }

    func jugeNextButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean?.count != 0 && password?.count != 0 && confirmPassword?.count != 0 {
            nextButton.backgroundColor = UIColor(hex: "#2e4af2")
            nextButton.isEnabled = true
        } else {
            nextButton.backgroundColor = UIColor(hex: "#E9EBF0")
            nextButton.isEnabled = false
        }
    }

    @IBAction func clickNextButton(_ sender: Any) {
        if canProceedNextStep() {
            UIApplication.shared.keyWindow?.endEditing(true)
            self.performSegue(withIdentifier: "nextButton", sender: sender)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextButton" {
            let walletModel = WalletModel()
            walletModel.name = name!
            let generateMnemonicController = segue.destination as! GenerateMnemonicController
            generateMnemonicController.walletModel = walletModel
            generateMnemonicController.password = password!
            generateMnemonicController.mnemonic = WalletManager.generateMnemonic()
        }
    }

    func canProceedNextStep() -> Bool {
        if password != confirmPassword {
            Toast.showToast(text: "Wallet.Create.passwordInconsistent".localized())
            return false
        }
        if case .invalid(let reason) = WalletNameValidator.validate(walletName: name ?? "") {
            Toast.showToast(text: reason)
            return false
        }
        if case .invalid(let reason) = PasswordValidator.validate(password: password ?? "") {
            Toast.showToast(text: reason)
            return false
        }
        return true
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "nextButton" {
            return false
        }
        return true
    }
}
