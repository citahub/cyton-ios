//
//  CreatWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class CreatWalletController: UITableViewController {

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
        password = sender.text
        jugeNextButtonEnabled()
    }

    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        confirmPassword = sender.text
        jugeNextButtonEnabled()
    }

    func jugeNextButtonEnabled() {
        if name?.count != 0 && password?.count != 0 && confirmPassword?.count != 0 {
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
        if name?.count == 0 {
            NeuLoad.showToast(text: "钱包名字不能为空")
            return false
        }
        if password != confirmPassword {
            NeuLoad.showToast(text: "两次密码不一致")
            return false
        }
        if !isThePasswordMeetCondition(password: password!) {
            return false
        }
        if !WalletTools.checkWalletName(name: name!) {
            NeuLoad.showToast(text: "钱包名字重复")
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
