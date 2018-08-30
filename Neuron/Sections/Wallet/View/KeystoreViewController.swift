//
//  KeystoreViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class KeystoreViewController: UITableViewController, ImportTextViewCellDelegate, ImportWalletViewModelDelegate, QRCodeControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var textViewCell: ImportTextViewCell!
    var name: String? = ""
    var password: String? = ""
    var keystore: String? = ""
    let viewModel = ImportWalletViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewCell.delegate = self
        viewModel.delegate = self
    }

    @IBAction func nameChanged(_ sender: UITextField) {
        name = sender.text
        jugeImportButtonEnabled()
    }

    @IBAction func passwordChanged(_ sender: UITextField) {
        password = sender.text
        jugeImportButtonEnabled()
    }

    func didGetTextViewText(text: String) {
        keystore = text
        jugeImportButtonEnabled()
    }

    func didBackQRCodeMessage(codeResult: String) {
        keystore = codeResult
        jugeImportButtonEnabled()
    }

    func jugeImportButtonEnabled() {
        if name!.isEmpty || password!.isEmpty || keystore!.isEmpty {
            importButton.backgroundColor = ColorFromString(hex: "#E9EBF0")
            importButton.isEnabled = false
        } else {
            importButton.backgroundColor = ColorFromString(hex: "#456CFF")
            importButton.isEnabled = true
        }
    }

    func didClickQRBtn() {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    @IBAction func importWallet(_ sender: UIButton) {
        viewModel.importKeyStoreWallet(keyStore: keystore!, password: password!, name: name!)
    }

    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}
