//
//  MnemonicViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class MnemonicViewController: UITableViewController, ImportTextViewCellDelegate, ImportWalletViewModelDelegate, QRCodeControllerDelegate, NEPickerViewDelegate {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var devirationPath: UILabel!
    @IBOutlet weak var textViewCell: ImportTextViewCell!
    let pickerView =  NEPickerView()
    var selectFormatId = "0"
    var name: String? = ""
    var password: String? = ""
    var confirmPassword: String? = ""
    var mnemonic: String? = ""
    let viewModel = ImportWalletViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewCell.delegate = self
        viewModel.delegate = self
        pickerView.delegate = self
        devirationPath.text = "m/44'/60'/0'/0/0"
    }

    @IBAction func nameChanged(_ sender: UITextField) {
        name = sender.text
        judgeImportButtonEnabled()
    }

    @IBAction func passwordChanged(_ sender: UITextField) {
        password = sender.text
        judgeImportButtonEnabled()
    }

    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        confirmPassword = sender.text
        judgeImportButtonEnabled()
    }

    func didGetTextViewText(text: String) {
        mnemonic = text
        judgeImportButtonEnabled()
    }

    func didBackQRCodeMessage(codeResult: String) {
        mnemonic = codeResult
        judgeImportButtonEnabled()
    }

    func callBackDictionnary(dict: [String: String]) {
        devirationPath.text = dict["name"]
        selectFormatId = dict["id"]!
    }

    func judgeImportButtonEnabled() {
        if name!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty || mnemonic!.isEmpty {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            pickerView.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
            pickerView.delegate = self
            pickerView.dataArray = [["name": "m/44'/60'/0'/0/0","id": "0"],["name": "m/44'/60'/0'/0","id": "1"],["name":"m/44'/60'/1'/0/0","id": "2"]]
            pickerView.selectDict = ["name": devirationPath.text!,"id": selectFormatId]
            UIApplication.shared.keyWindow?.addSubview(pickerView)
        }
    }

    @IBAction func importWallet(_ sender: UIButton) {
        viewModel.importWalletWithMnemonic(mnemonic: mnemonic!, password: password!, confirmPassword: confirmPassword!, devirationPath: devirationPath.text!, name: name!)
    }

    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}
