//
//  TransactionGasPriceViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import Web3swift
import BigInt

class TransactionGasPriceViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var estimatedGasPriceLabel: UILabel!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    var service: TransactionParamBuilder!

    private let minGasPrice = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let gasPrice = service.gasPrice.weiToGwei()
        estimatedGasPriceLabel.text = "以太坊推荐值 \(gasPrice)Gwei" // TODO: trim trailing zeros
        gasPriceTextField.text = "\(gasPrice)"
        gasLimitTextField.text = "\(service.gasLimit)"
        gasPriceTextField.isEnabled = true
        gasLimitTextField.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }
    }

    @IBAction func dismiss() {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    @IBAction func confirm(_ sender: Any) {
        let gasPrice = Double(gasPriceTextField.text!)!
        if gasPrice < minGasPrice {
            Toast.showToast(text: "您的GasPrice设置过低，建议输入推荐值以快速转账")
            return
        }
        service.gasPrice = gasPrice.gweiToWei()
        service.gasLimit = UInt64(gasLimitTextField.text!) ?? GasCalculator.defaultGasLimit
        dismiss()
    }
}

extension TransactionGasPriceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let character: String
        if textField == gasPriceTextField {
            if textField.text!.contains(".") {
                character = "0123456789"
            } else {
                character = "0123456789."
            }
        } else {
            character = "0123456789"
        }
        guard CharacterSet(charactersIn: character).isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
}
