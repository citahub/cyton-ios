//
//  TransactionGasCostTableViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionGasCostTableViewController: UITableViewController {
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var gasCostLabel: UILabel!
    @IBOutlet weak var dataTextView: UITextView!
    @IBOutlet weak var dataTextPlaceholderLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    var param: (TransactionParamBuilder, TokenModel)!
    private var paramBuilder: TransactionParamBuilder!
    private var observers = [NSKeyValueObservation]()
    private let minGasPrice = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        paramBuilder = TransactionParamBuilder(token: param.1)
        paramBuilder.from = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        paramBuilder.to = param.0.to

        gasPriceTextField.text = paramBuilder.fetchedGasPrice.weiToGwei().trailingZerosTrimmed
        gasLimitTextField.text = paramBuilder.gasLimit.description
        observers.append(paramBuilder.observe(\.txFeeNatural, options: [.initial]) { [weak self](_, _) in
            self?.updateGasCost()
        })
    }

    @IBAction func confirm() {
        let gasPrice = Double(gasPriceTextField.text!)!
        if gasPrice < minGasPrice {
            Toast.showToast(text: "您的GasPrice设置过低，建议输入推荐值以快速转账")
            return
        }
        param.0.gasPrice = paramBuilder.gasPrice
        param.0.gasLimit = paramBuilder.gasLimit
        navigationController?.popViewController(animated: true)
    }

    private func updateGasCost() {
        gasCostLabel.text = "\(paramBuilder.txFeeNatural.decimal) \(paramBuilder.nativeCoinSymbol)"
    }
}

extension TransactionGasCostTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var character = "0123456789"
        if !(textField.text?.contains(".") ?? false) {
            character += "."
        }
        guard CharacterSet(charactersIn: character).isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == gasPriceTextField {
            paramBuilder.gasPrice = Double(gasPriceTextField.text!)!.gweiToWei()
        } else if textField == gasLimitTextField {
            paramBuilder.gasLimit = UInt64(gasLimitTextField.text!) ?? GasCalculator.defaultGasLimit
        }
    }
}

extension TransactionGasCostTableViewController: UITextPasteDelegate {

}

extension TransactionGasCostTableViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let character = "0123456789abcdefABCDEF"
        guard CharacterSet(charactersIn: character).isSuperset(of: CharacterSet(charactersIn: text)) else {
            return false
        }
        return true
    }
}
