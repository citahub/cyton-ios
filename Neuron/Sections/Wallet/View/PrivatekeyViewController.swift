//
//  PrivatekeyViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class PrivatekeyViewController: UITableViewController, ImportTextViewCellDelegate, ImportWalletViewModelDelegate, QRCodeControllerDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var textViewCell: ImportTextViewCell!
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    var privateKey: String? = ""
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
    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        confirmPassword = sender.text
        jugeImportButtonEnabled()
    }
    func didGetTextViewText(text: String) {
        privateKey = text
        jugeImportButtonEnabled()
    }
    func didBackQRCodeMessage(codeResult: String) {
        privateKey = codeResult
        jugeImportButtonEnabled()
    }

    func jugeImportButtonEnabled() {
        if name!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty || privateKey!.isEmpty {
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
        viewModel.importPrivateWallet(privateKey: privateKey!, password: password!, confirmPassword: confirmPassword!, name: name!)
    }

    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}
