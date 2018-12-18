//
//  TransactionGasCostViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import Web3swift

class TransactionGasCostViewController: UITableViewController {
    @IBOutlet private weak var gasPriceTitleLabel: UILabel!
    @IBOutlet private weak var gasLimitTitleLabel: UILabel!
    @IBOutlet private weak var gasPriceTextField: UITextField!
    @IBOutlet private weak var gasLimitTextField: UITextField!
    @IBOutlet private weak var gasCostLabel: UILabel!
    @IBOutlet private weak var gasCostDescLabel: UILabel!
    @IBOutlet private weak var inputDataTextView: UITextView!
    @IBOutlet private weak var dataTextPlaceholderLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var gasCostTitleLabel: UILabel!
    @IBOutlet private weak var extenDataTitleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var hexHighlightView: UIView!
    @IBOutlet private weak var utf8HighlightView: UIView!
    @IBOutlet private weak var dataTextView: UITextView!
    @IBOutlet private weak var gasPriceSymbolLabel: UILabel!
    @IBOutlet private weak var gasPriceSymbolWidthLayout: NSLayoutConstraint!
    private var paramBuilder: TransactionParamBuilder!
    private var observers = [NSKeyValueObservation]()
    private let minGasPrice = 1.0
    var dataString: String?
    var param: TransactionParamBuilder!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction.Send.gasCostSetting".localized()
        extenDataTitleLabel.text = "Transaction.Send.extenData".localized()
        descLabel.text = "Transaction.Send.gasCostSettingDesc".localized()
        confirmButton.setTitle("Common.confirm".localized(), for: .normal)
        gasPriceTextField.placeholder = "Transaction.Send.input".localized()
        gasLimitTextField.placeholder = "Transaction.Send.input".localized()
        dataTextPlaceholderLabel.text = "Transaction.Send.inputHexData".localized()

        paramBuilder = TransactionParamBuilder(builder: param)
        observers.append(paramBuilder.observe(\.txFeeText, options: [.initial]) { [weak self](_, _) in
            self?.updateGasCost()
        })
        observers.append(param.observe(\.gasTokenPrice, options: [.initial]) { [weak self](_, _) in
            self?.updateGasCost()
        })
        dataString != nil ? switchDataToHex() : nil
    }

    // MARK: Action

    @IBAction func switchDataToHex() {
        hexHighlightView.backgroundColor = UIColor(named: "tint_color")
        utf8HighlightView.backgroundColor = UIColor(named: "weak_1_color")
        dataTextView.text = dataString
    }

    @IBAction func switchDataToUtf8() {
        hexHighlightView.backgroundColor = UIColor(named: "weak_1_color")
        utf8HighlightView.backgroundColor = UIColor(named: "tint_color")
        dataTextView.text = String(decoding: Data.fromHex(dataString!)!, as: UTF8.self)
    }

    @IBAction func confirm() {
        paramBuilder.gasLimit = UInt64(gasLimitTextField.text!) ?? GasCalculator.defaultGasLimit
        if paramBuilder.tokenType == .ether || paramBuilder.tokenType == .erc20 {
            paramBuilder.gasPrice = BigUInt.parseToBigUInt(gasPriceTextField.text!, 9)
            let gasPrice = Double(gasPriceTextField.text!)!
            if gasPrice < minGasPrice {
                Toast.showToast(text: "Transaction.Send.gasPriceSettingIsTooLow".localized())
                return
            }
            if paramBuilder.data.count > 0 {
                let estimateGasLimit = paramBuilder.estimateGasLimit()
                if paramBuilder.gasLimit < UInt(estimateGasLimit) {
                    Toast.showToast(text: "Transaction.Send.gasLimitSettingIsTooLow".localized())
                    return
                }
            } else {
                if paramBuilder.gasLimit < GasCalculator.defaultGasLimit {
                    Toast.showToast(text: "Transaction.Send.gasLimitSettingIsTooLow".localized())
                    return
                }
            }
        } else if paramBuilder.tokenType == .appChain || paramBuilder.tokenType == .appChainErc20 {
            gasPriceTextField.isEnabled = false
            if paramBuilder.gasLimit < paramBuilder.estimateGasLimit() {
                Toast.showToast(text: "Transaction.Send.quotaLimitSettingIsTooLow".localized())
                return
            }
        }
        param.gasPrice = paramBuilder.gasPrice
        param.gasLimit = paramBuilder.gasLimit
        param.data = inputDataTextView.text.data(using: .utf8) ?? Data()
        navigationController?.popViewController(animated: true)
    }

    private func updateGasCost() {
        switch paramBuilder.tokenType {
        case .appChain, .appChainErc20:
            gasPriceTextField.text = paramBuilder.gasPrice.toAmountText(paramBuilder.gasTokenDecimals)
            gasPriceSymbolLabel.text = "NATT"
            gasPriceTextField.isEnabled = false
            gasPriceTitleLabel.text = "Quota Price"
            gasLimitTitleLabel.text = "Quota Limit"
            gasCostTitleLabel.text = "Quota 费用"
        case .ether, .erc20:
            gasPriceTextField.text = paramBuilder.gasPrice.toGweiText()
            gasPriceSymbolLabel.text = "Gwei"
            gasPriceTitleLabel.text = "Gas Price"
            gasLimitTitleLabel.text = "Gas Limit"
            gasCostTitleLabel.text = "Transaction.Send.gasCost".localized()
        }
        gasPriceSymbolWidthLayout.constant = gasPriceSymbolLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: 100, height: 20), limitedToNumberOfLines: 1).size.width

        gasLimitTextField.text = paramBuilder.gasLimit.description
        gasCostLabel.text = "\(paramBuilder.txFeeText) \(paramBuilder.nativeCoinSymbol)"
        gasCostDescLabel.text = "≈\(gasLimitTitleLabel.text!)(\(gasLimitTextField.text!))*\(gasPriceTitleLabel.text!)(\(gasPriceTextField.text!) \(gasPriceSymbolLabel.text!))"
        if paramBuilder.gasTokenPrice > 0 {
            let amount = paramBuilder.txFee.toDecimalNumber().multiplying(by: NSDecimalNumber(value: paramBuilder.gasTokenPrice))
            gasCostLabel.text = gasCostLabel.text! + " ≈ \(paramBuilder.currencySymbol)" + amount.formatterToString(4)
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension TransactionGasCostViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var character = "0123456789"
        if textField.text!.contains(".") {
            character += "."
        }
        guard CharacterSet(charactersIn: character).isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == gasPriceTextField {
            paramBuilder.gasPrice = BigUInt.parseToBigUInt(gasPriceTextField.text!, 9)
        } else if textField == gasLimitTextField {
            paramBuilder.gasLimit = UInt64(gasLimitTextField.text!) ?? GasCalculator.defaultGasLimit
        }
    }
}

extension TransactionGasCostViewController: UITextPasteDelegate {
}

extension TransactionGasCostViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            if dataString == nil {
                return 0.0
            }
        }
        if indexPath.row == 3 {
            if paramBuilder.tokenType == .erc20 || paramBuilder.tokenType == .appChainErc20 || dataString != nil {
                return 0.0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isHidden = cell.bounds.size.height == 0.0
    }
}

extension TransactionGasCostViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let character = "0123456789abcdefABCDEF"
        guard CharacterSet(charactersIn: character).isSuperset(of: CharacterSet(charactersIn: text)) else {
            return false
        }
        dataTextPlaceholderLabel.isHidden = textView.text.count + (text.count - range.length) > 0
        return true
    }
}
