//
//  AdvancedViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/11/1.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

protocol AdvancedViewControllerDelegate: class {
    func getCustomGas(gasPrice: BigUInt, gas: BigUInt)
}

class AdvancedViewController: UIViewController {
    var dataString = ""
    var gasLimit = BigUInt()
    private var gasPrice = BigUInt()
    private var inputGasPrice: String?
    weak var delegate: AdvancedViewControllerDelegate?

    @IBOutlet weak var ethereumSuggestLabel: UILabel!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var dataTextView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assignmentForUI()
        view.frame = CGRect(x: 0, y: ScreenSize.height, width: ScreenSize.width, height: ScreenSize.height)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
        }, completion: { (_) in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabbedButtonView.buttonTitles = ["HEX", "UTF8"]
        tabbedButtonView.delegate = self
        gasPriceTextField.delegate = self
    }

    func assignmentForUI() {
        dataTextView.text = dataString
        Toast.showHUD()
        DispatchQueue.global().async {
            let web3 = Web3Network().getWeb3()
            guard let gp = web3.eth.getGasPrice().value else {
                self.ethereumSuggestLabel.text = "以太坊推荐 8"
                self.gasPrice = BigUInt(8)
                return
            }
            DispatchQueue.main.async {
                self.gasPrice = gp
                let ethereumGasPrice = Web3Utils.formatToEthereumUnits(gp, toUnits: .Gwei, decimals: 4, fallbackToScientific: false) ?? "8"
                self.ethereumSuggestLabel.text = "以太坊推荐 " + ethereumGasPrice + "Gwei"
                self.formatValue(gasPrice: self.gasPrice)
                Toast.hideHUD()
            }
        }
    }

    func formatValue(gasPrice: BigUInt) {
        let ethereumGasPrice = Web3Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, decimals: 4, fallbackToScientific: false) ?? "8"
        let gas = Web3Utils.formatToEthereumUnits(gasPrice * self.gasLimit, toUnits: .eth, decimals: 4, fallbackToScientific: true) ?? "0"
        self.gasLabel.text = "Gas费用：\(gas) eth = Gaslimit(\(self.gasLimit.description))*Gasprice(\(ethereumGasPrice))"
    }

    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if let gasPrice = sender.text {
            inputGasPrice = gasPrice
            let finalGasPrice = Web3Utils.parseToBigUInt(gasPrice, units: .Gwei)!
            formatValue(gasPrice: finalGasPrice)
        }
    }

    func hideView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: ScreenSize.height, width: ScreenSize.width, height: ScreenSize.height)
        }, completion: { (_) in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            self.view.removeFromSuperview()
        })
    }

    @IBAction func closeButton(_ sender: UIButton) {
        hideView()
    }

    @IBAction func sureAdvanceButton(_ sender: UIButton) {
        guard let inputGasPrice = inputGasPrice else {
            Toast.showToast(text: "请输入GasPrice")
            return
        }
        let finalGasPrice = Web3Utils.parseToBigUInt(inputGasPrice, units: .Gwei)!
        if finalGasPrice < gasPrice {
            let gasPriceString = Web3Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, decimals: 4, fallbackToScientific: true) ?? "0"
            Toast.showToast(text: "请输入的GasPrice不小于\(gasPriceString) Gwei")
            return
        }
        delegate?.getCustomGas(gasPrice: finalGasPrice, gas: finalGasPrice * self.gasLimit)
        hideView()
    }
}

extension AdvancedViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == gasPriceTextField {
            guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let gasPrice = textField.text {
            inputGasPrice = gasPrice
            let finalGasPrice = Web3Utils.parseToBigUInt(gasPrice, units: .Gwei)!
            formatValue(gasPrice: finalGasPrice)
        }
    }
}

extension AdvancedViewController: TabbedButtonsViewDelegate {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        if index == 0 {
            dataTextView.text = dataString
        } else {
            dataTextView.text = String(decoding: Data.fromHex(dataString)!, as: UTF8.self)
        }
    }
}
