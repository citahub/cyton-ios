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

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ethereumSuggestLabel: UILabel!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var dataTextView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assignmentForUI()
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.backgroundView.alpha = 0.5
            self.contentView.transform = CGAffineTransform.identity
        }
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
            do {
                let web3 = EthereumNetwork().getWeb3()
                let gasPrice = try web3.eth.getGasPrice()
                DispatchQueue.main.async {
                    self.gasPrice = gasPrice
                    let ethereumGasPrice = Web3Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, decimals: 4, fallbackToScientific: false) ?? "8"
                    self.ethereumSuggestLabel.text = "DApp.Advanced.ETHRecommend".localized() + ethereumGasPrice + "Gwei"
                    self.formatValue(gasPrice: gasPrice)
                    Toast.hideHUD()
                }
            } catch {
                DispatchQueue.main.async {
                    self.ethereumSuggestLabel.text = "DApp.Advanced.ETHRecommend".localized() + "8"
                    self.gasPrice = BigUInt(8)
                }
            }
        }
    }

    func formatValue(gasPrice: BigUInt) {
        let ethereumGasPrice = Web3Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, decimals: 4, fallbackToScientific: false) ?? "8"
        let gas = Web3Utils.formatToEthereumUnits(gasPrice * self.gasLimit, toUnits: .eth, decimals: 4, fallbackToScientific: true) ?? "0"
        self.gasLabel.text = "DApp.Advanced.Gas".localized() + "：\(gas) ETH = Gaslimit(\(self.gasLimit.description))*Gasprice(\(ethereumGasPrice))"
    }

    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if let gasPrice = sender.text {
            inputGasPrice = gasPrice
            let finalGasPrice = Web3Utils.parseToBigUInt(gasPrice, units: .Gwei)!
            formatValue(gasPrice: finalGasPrice)
        }
    }

    func hideView() {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    @IBAction func closeButton(_ sender: UIButton) {
        hideView()
    }

    @IBAction func sureAdvanceButton(_ sender: UIButton) {
        guard let inputGasPrice = inputGasPrice else {
            Toast.showToast(text: "DApp.Advanced.EmptyGasPrice".localized())
            return
        }
        let finalGasPrice = Web3Utils.parseToBigUInt(inputGasPrice, units: .Gwei)!
        if finalGasPrice < gasPrice {
            let gasPriceString = Web3Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, decimals: 4, fallbackToScientific: true) ?? "0"
            Toast.showToast(text: "DApp.Advanced.MinGasPrice".localized() + "\(gasPriceString) Gwei")
            return
        }
        delegate?.getCustomGas(gasPrice: finalGasPrice, gas: finalGasPrice * self.gasLimit)
        hideView()
    }
}

extension AdvancedViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == gasPriceTextField {
            let character: String
            if (textField.text?.contains("."))! {
                character = "0123456789"
            } else {
                character = "0123456789."
            }
            guard CharacterSet(charactersIn: character).isSuperset(of: CharacterSet(charactersIn: string)) else {
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
