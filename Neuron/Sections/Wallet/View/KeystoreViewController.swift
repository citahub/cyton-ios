//
//  KeystoreViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class KeystoreViewController: UITableViewController, ImportWalletViewModelDelegate, QRCodeControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var keyStoreTextView: RSKPlaceholderTextView!
    var name: String? = ""
    var password: String? = ""
    var keystore: String? = ""
    let viewModel = ImportWalletViewModel()

    @IBOutlet weak var titleContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        keyStoreTextView.delegate = self
        viewModel.delegate = self

        let titleHeight = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: titleLabel.bounds.size.width, height: 100), limitedToNumberOfLines: 0).size.height
        titleContentView.frame = CGRect(origin: titleContentView.frame.origin, size: CGSize(width: titleContentView.bounds.size.width, height: max(titleHeight + 12, 35.0)))
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

    func didBackQRCodeMessage(codeResult: String) {
        keystore = codeResult
        keyStoreTextView.text = codeResult
        judgeImportButtonEnabled()
    }

    func judgeImportButtonEnabled() {
        let nameClean = name?.trimmingCharacters(in: .whitespaces)
        if nameClean!.isEmpty || password!.isEmpty || keystore!.isEmpty {
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
        viewModel.importKeystoreWallet(keystore: keystore!, password: password!, name: name!)
    }

    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension KeystoreViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        keystore = textView.text
        judgeImportButtonEnabled()
    }
}
