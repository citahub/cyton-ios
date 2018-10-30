//
//  CreatWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class CreateWalletController: UITableViewController {

    @IBOutlet weak var nextButton: UIButton!
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "创建钱包"
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
            nextButton.backgroundColor = ColorFromString(hex: "#2e4af2")
            nextButton.isEnabled = true
        } else {
            nextButton.backgroundColor = ColorFromString(hex: "#E9EBF0")
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
            generateMnemonicController.mnemonicStr = WalletTool.generateMnemonic()
        }
    }

    func canProceedNextStep() -> Bool {
        if case .invalid(let reason) = WalletNameValidator.validate(walletName: name ?? "") {
            Toast.showToast(text: reason)
            return false
        }
        if case .invalid(let reason) = PasswordValidator.validate(password: password ?? "") {
            Toast.showToast(text: reason)
            return false
        }
        if password != confirmPassword {
            Toast.showToast(text: "两次密码不一致")
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
