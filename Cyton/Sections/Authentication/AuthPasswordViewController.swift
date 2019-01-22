//
//  PasswordAuthenticationViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class AuthPasswordViewController: UIViewController, AuthenticationMode, UITextFieldDelegate, AuthSelectWalletViewControllerDelegate {
    weak var delegate: AuthenticationDelegate?
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var selectWalletButton: UIButton!

    var currentWallet: WalletModel? {
        didSet {
            walletNameLabel.text = currentWallet?.name
            passwordTextField.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentWallet = AppModel.current.currentWallet
        passwordTextField.placeholder = "Authentication.walletPassword".localized()
        confirmButton.setTitle("Common.confirm".localized(), for: .normal)
        selectWalletButton.setTitle("SwitchWallet.title".localized(), for: .normal)
    }

    @IBAction func selectWallet(_ sender: Any) {
        guard let navigationController = view.window?.rootViewController as? UINavigationController else { return }
        let controller: AuthSelectWalletViewController = UIStoryboard(name: .authentication).instantiateViewController()
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    @IBAction func confirm(_ sender: Any) {
        guard let currentWallet = currentWallet, let wallet = currentWallet.wallet else {
            return
        }
        guard let password = passwordTextField.text else { return }
        passwordTextField.resignFirstResponder()
        Toast.showHUD()
        DispatchQueue.global().async {
            let isPasswordCorrect = WalletManager.default.verifyPassword(wallet: wallet, password: password)
            DispatchQueue.main.sync { [weak self] in
                Toast.hideHUD()
                if isPasswordCorrect {
                    self?.delegate?.authenticationSuccessful()
                } else {
                    Toast.showToast(text: "Authentication.walletPasswordError".localized())
                }
            }
        }
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let range = Range(range, in: textField.text ?? "") {
            let newStr = textField.text?.replacingCharacters(in: range, with: string)
            if newStr?.lengthOfBytes(using: .utf8) ?? 0 >= 1 {
                confirmButton.backgroundColor = UIColor(red: 54/255.0, green: 59/255.0, blue: 255/255.0, alpha: 1.0)
                confirmButton.isEnabled = true
            } else {
                confirmButton.backgroundColor = UIColor(red: 233/255.0, green: 235/255.0, blue: 240/255.0, alpha: 1.0)
                confirmButton.isEnabled = false
            }
        }
        return true
    }

    // MARK: - AuthSelectWalletViewControllerDelegate
    func selectWalletController(_ controller: AuthSelectWalletViewController, didSelectWallet model: WalletModel) {
        currentWallet = model
    }
}
