//
//  ChangePasswordController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ChangePasswordController: UITableViewController, UITextFieldDelegate {
    @IBOutlet private weak var walletIconView: UIImageView!
    @IBOutlet private weak var walletNameLabel: UILabel!
    @IBOutlet private weak var oldPasswordTextField: UITextField!
    @IBOutlet private weak var newPasswordTextField: UITextField!
    @IBOutlet private weak var reNewPasswordTextField: UITextField!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Details.changePassword".localized()
        view.backgroundColor = UIColor(hex: "#f5f5f9")
        oldPasswordTextField.placeholder = "Wallet.Details.ChangePassword.inputPassword".localized()
        newPasswordTextField.placeholder = "Wallet.Details.ChangePassword.inputNewPassword".localized()
        reNewPasswordTextField.placeholder = "Wallet.Details.ChangePassword.repeatNewPassword".localized()
        warningLabel.text = "Wallet.Details.ChangePassword.warning".localized()
        descLabel.text = "Wallet.Import.setPasswordDesc".localized()
        confirmButton.setTitle("Wallet.Details.changePassword".localized(), for: .normal)

        let walletModel = AppModel.current.currentWallet!
        walletNameLabel.text = walletModel.name
        walletIconView.image = walletModel.icon.image
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        let oldPassword = textField == oldPasswordTextField ? newString : oldPasswordTextField.text ?? ""
        let newPassword = textField == newPasswordTextField ? newString : newPasswordTextField.text ?? ""
        let reNewPassword = textField == reNewPasswordTextField ? newString : reNewPasswordTextField.text ?? ""

        if oldPassword.lengthOfBytes(using: .utf8) >= 8 &&
            newPassword.lengthOfBytes(using: .utf8) >= 8 &&
            reNewPassword.lengthOfBytes(using: .utf8) >= 8 {
            confirmButton.backgroundColor = UIColor(red: 80/255.0, green: 114/255.0, blue: 251/255.0, alpha: 1.0)
            confirmButton.isEnabled = true
        } else {
            confirmButton.backgroundColor = UIColor(red: 233/255.0, green: 235/255.0, blue: 240/255.0, alpha: 1.0)
            confirmButton.isEnabled = false
        }
        return true
    }

    @IBAction func confirm(_ sender: Any) {
        if oldPasswordTextField.text == newPasswordTextField.text {
            Toast.showToast(text: "Wallet.Details.ChangePassword.newPasswordIsSameAsOld".localized())
            return
        }
        if newPasswordTextField.text! != reNewPasswordTextField.text! {
            Toast.showToast(text: "Wallet.Details.ChangePassword.inconsistentPasswords".localized())
            return
        }
        if case .invalid(let reason) = PasswordValidator.validate(password: newPasswordTextField.text!) {
            Toast.showToast(text: reason)
            return
        }
        Toast.showHUD(text: "Wallet.Details.ChangePassword.loading".localized())
        let oldPassword = oldPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let walletModel = AppModel.current.currentWallet!
        let wallet = WalletManager.default.wallet(for: walletModel.address)!
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            do {
                try WalletManager.default.updatePassword(wallet: wallet, password: oldPassword, newPassword: newPassword)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: "Wallet.Details.ChangePassword.success".localized())
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                }
            }
        }
    }
}
