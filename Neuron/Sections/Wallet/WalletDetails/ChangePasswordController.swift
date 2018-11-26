//
//  ChangePasswordController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ChangePasswordController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var walletIconView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var reNewPasswordTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改密码"
        view.backgroundColor = UIColor(hex: "#f5f5f9")

        let walletModel = AppModel.current.currentWallet!
        walletNameLabel.text = walletModel.name
        walletIconView.image = UIImage(data: walletModel.iconData)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        let oldPassword = textField == oldPasswordTextField ? newString : oldPasswordTextField.text ?? ""
        let newPassword = textField == newPasswordTextField ? newString : newPasswordTextField.text ?? ""
        let reNewPassword = textField == reNewPasswordTextField ? newString : reNewPasswordTextField.text ?? ""

        if oldPassword.lengthOfBytes(using: .utf8) >= 8 &&
            newPassword.lengthOfBytes(using: .utf8) >= 8 &&
            reNewPassword == newPassword {
            confirmButton.backgroundColor = UIColor(red: 80/255.0, green: 114/255.0, blue: 251/255.0, alpha: 1.0)
            confirmButton.isEnabled = true
        } else {
            confirmButton.backgroundColor = UIColor(red: 233/255.0, green: 235/255.0, blue: 240/255.0, alpha: 1.0)
            confirmButton.isEnabled = false
        }
        return true
    }

    @IBAction func confirm(_ sender: Any) {
        if case .invalid(let reason) = PasswordValidator.validate(password: newPasswordTextField.text!) {
            Toast.showToast(text: reason)
            return
        }
        if oldPasswordTextField.text == newPasswordTextField.text {
            Toast.showToast(text: "您输入的密码和原密码一致，请重新输入")
            return
        }
        if newPasswordTextField.text! != reNewPasswordTextField.text! {
            Toast.showToast(text: "两次新密码输入不一致")
            return
        }
        Toast.showHUD(text: "修改密码中...")
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
                    Toast.showToast(text: "密码修改成功，请牢记！")
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
