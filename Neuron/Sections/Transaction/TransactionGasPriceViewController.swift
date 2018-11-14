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

    override func viewDidLoad() {
        super.viewDidLoad()
        let estimatedGasPrice = service.gasPrice / BigUInt(10).power(9)
        estimatedGasPriceLabel.text = "以太坊推荐值 \(estimatedGasPrice)Gwei"
        // TODO: fix numbers and precision
        let gasPrice = Double(service.gasPrice) / pow(10, 9)
        if gasPrice == Double(UInt(gasPrice)) {
            gasPriceTextField.text = "\(UInt(gasPrice))"
        } else {
            gasPriceTextField.text = "\(gasPrice)"
        }
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
        let newGasPrice = BigUInt(gasPriceTextField.text!)! * BigUInt(10).power(9)
        if newGasPrice < service.gasPrice {
            Toast.showToast(text: "您的GasPrice设置过低，请确保输入大于等于推荐值以快速转账")
            return
        }
        service.gasPrice = newGasPrice
        service.gasLimit = UInt64(gasLimitTextField.text!) ?? 0
        dismiss()
    }
}

extension TransactionGasPriceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let character: String
        if textField == gasPriceTextField {
            if (textField.text?.contains("."))! {
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
