//
//  MnemonicViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class MnemonicViewController: UITableViewController, ImportWalletViewModelDelegate, QRCodeControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var mnemonicTextView: RSKPlaceholderTextView!

    var selectFormatId = "0"
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    var mnemonic: String? = ""
    let viewModel = ImportWalletViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        mnemonicTextView.placeholder = "请输入助记词+空格"
        mnemonicTextView.delegate = self
        viewModel.delegate = self
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
        mnemonic = text
        viewModel.isUseQRCode = false
        judgeImportButtonEnabled()
    }

    func didBackQRCodeMessage(codeResult: String) {
        mnemonic = codeResult
        viewModel.isUseQRCode = true
        mnemonicTextView.text = codeResult
        judgeImportButtonEnabled()
    }

    func judgeImportButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty || mnemonic!.isEmpty {
            importButton.backgroundColor = ColorFromString(hex: "#E9EBF0")
            importButton.isEnabled = false
        } else {
            importButton.backgroundColor = ColorFromString(hex: "#456CFF")
            importButton.isEnabled = true
        }
    }

   @IBAction func didClickQRBtn() {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    @IBAction func importWallet(_ sender: UIButton) {
        viewModel.importWalletWithMnemonic(mnemonic: mnemonic!, password: password!, confirmPassword: confirmPassword!, name: name!)
    }

    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension MnemonicViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        mnemonic = textView.text
        judgeImportButtonEnabled()
    }
}
