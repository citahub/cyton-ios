//
//  EthGasViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import BigInt
import web3swift
import struct BigInt.BigUInt

protocol EthGasViewControllerDelegate: class {
    func getTransactionGasPriceAndData(ethGasViewController: EthGasViewController, gasPrice: BigUInt, data: Data)
    func getTransactionCostGas(gas: String)
}

class EthGasViewController: UIViewController {
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasTextField: UITextField!
    @IBOutlet weak var hexTextView: RSKPlaceholderTextView!
    weak var delegate: EthGasViewControllerDelegate?
    let viewModel = TAViewModel()
    var data = Data()
    var gas: Float = 60000
    var gasPrice: BigUInt = 4000000000

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.getTransactionGasPriceAndData(ethGasViewController: self, gasPrice: gasPrice, data: data)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gasPriceTextField.delegate = self
        gasTextField.delegate = self
        hexTextView.delegate = self
        gasPriceTextField.text = Web3.Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, fallbackToScientific: false)
        gasTextField.text = String(gas)
        setGasLabelValue()
        getGasPrice()
    }

    func setGasLabelValue() {
        let gasCosted = gas * Float(gasPrice)
        let totleGas = Web3.Utils.formatToEthereumUnits(BigUInt(gasCosted), toUnits: .eth, decimals: 4, fallbackToScientific: false)
        gasLabel.text = totleGas! + "  eth"
        delegate?.getTransactionCostGas(gas: gasLabel.text!)
    }

    func getGasPrice() {
        viewModel.getGasPrice { (result) in
            switch result {
            case .success(let gasPriceResult):
                self.gasPrice = gasPriceResult
                self.gasPriceTextField.text = Web3.Utils.formatToEthereumUnits(gasPriceResult, toUnits: .Gwei, fallbackToScientific: false)
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
        }
    }
}

extension EthGasViewController: UITextFieldDelegate, UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789.").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1000 {
            guard let textFieldText = textField.text else {
                return
            }
            let tempGasPrice = Web3.Utils.parseToBigUInt(textFieldText, units: .Gwei)!
            if tempGasPrice < gasPrice || tempGasPrice > (gasPrice * 10) {
                let minGasPrice = Web3.Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, fallbackToScientific: false) ?? ""
                let maxGasPrice = Web3.Utils.formatToEthereumUnits(gasPrice * 10, toUnits: .Gwei, fallbackToScientific: false) ?? ""
                Toast.showToast(text: "Gas Price必须大于\(minGasPrice)并且小于\(maxGasPrice) Gwei")
                textField.text = Web3.Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, fallbackToScientific: false)
                return
            }
            gasPrice = Web3.Utils.parseToBigUInt(textFieldText, units: .Gwei)!
        }
        setGasLabelValue()
        delegate?.getTransactionGasPriceAndData(ethGasViewController: self, gasPrice: gasPrice, data: data)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let dataString = textView.text else {
            return
        }
        guard let tempData = Data.fromHex(dataString) else {
            return
        }
        data = tempData
        delegate?.getTransactionGasPriceAndData(ethGasViewController: self, gasPrice: gasPrice, data: tempData)
    }

}
