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
            WalletTools.generateMnemonic { (mnemonic) in
                generateMnemonicController.mnemonicStr = mnemonic
            }
        }
    }

    func canProceedNextStep() -> Bool {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean?.count == 0 {
            Toast.showToast(text: "钱包名字不能为空")
            return false
        }
        if name!.count > 15 {
            Toast.showToast(text: "钱包名字不能超过15个字符")
            return false
        }
        if password?.count == 0 {
            Toast.showToast(text: "密码不能为空")
            return false
        }
        if password != confirmPassword {
            Toast.showToast(text: "两次密码不一致")
            return false
        }
        if !PasswordValidator.isValid(password: password!) {
            return false
        }
        if !WalletTools.checkWalletName(name: name!) {
            Toast.showToast(text: "钱包名字重复")
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
