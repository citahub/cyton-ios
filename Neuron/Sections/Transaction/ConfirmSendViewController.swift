//
//  ConfirmSendViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/17.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

protocol ConfirmSendViewControllerDelegate: class {
    func closePayCoverView()
    func sendTransaction(confirmSendViewController: ConfirmSendViewController, password: String)
}

class ConfirmSendViewController: UIViewController {
    weak var delegate: ConfirmSendViewControllerDelegate?
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    private var password: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
    }

    @IBAction func clickCloseButton(_ sender: UIButton) {
        delegate?.closePayCoverView()
    }

    @IBAction func clickSendTransactionButton(_ sender: UIButton) {
        if isPasswordCorrect() {
            delegate?.sendTransaction(confirmSendViewController: self, password: password)
        }
    }

    func isPasswordCorrect() -> Bool {
        if password.count == 0 {
            NeuLoad.showToast(text: "请输入钱包密码")
            return false
        }
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        if walletModel.MD5screatPassword != CryptTools.changeMD5(password: password) {
            NeuLoad.showToast(text: "密码不正确请重新输入")
            return false
        }
        return true
    }
}

extension ConfirmSendViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        password = textField.text ?? ""
    }
}
