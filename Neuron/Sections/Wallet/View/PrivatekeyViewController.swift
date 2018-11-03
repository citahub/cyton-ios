//
//  PrivatekeyViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class PrivatekeyViewController: UITableViewController, ImportWalletViewModelDelegate, QRCodeViewControllerDelegate, EnterBackOverlayPresentable {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var privatekeyTextView: RSKPlaceholderTextView!
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    var privateKey: String? = ""
    let viewModel = ImportWalletViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        privatekeyTextView.delegate = self
        viewModel.delegate = self
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
        viewModel.isUseQRCode = false
        judgeImportButtonEnabled()
    }
    func didBackQRCodeMessage(codeResult: String) {
        privateKey = codeResult
        viewModel.isUseQRCode = true
        privatekeyTextView.text = codeResult
        judgeImportButtonEnabled()
    }

    func judgeImportButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty || privateKey!.isEmpty {
            importButton.backgroundColor = ColorFromString(hex: "#E9EBF0")
            importButton.isEnabled = false
        } else {
            importButton.backgroundColor = ColorFromString(hex: "#456CFF")
            importButton.isEnabled = true
        }
    }

   @IBAction func didClickQRBtn() {
        let qRCodeViewController = QRCodeViewController()
        qRCodeViewController.delegate = self
        self.navigationController?.pushViewController(qRCodeViewController, animated: true)
    }

    @IBAction func importWallet(_ sender: UIButton) {
        viewModel.importPrivateWallet(privateKey: privateKey!, password: password!, confirmPassword: confirmPassword!, name: name!)
    }

    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension PrivatekeyViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        privateKey = textView.text
        judgeImportButtonEnabled()
    }
}
