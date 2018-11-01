//
//  TransactionGasPriceViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionGasPriceViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    var service: TransactionService!

    override func viewDidLoad() {
        super.viewDidLoad()
        gasPriceTextField.text = "\(service.gasPrice)"
        gasLimitTextField.text = "\(service.gasLimit)"
        gasPriceTextField.isEnabled = service.changeGasPriceEnable
        gasLimitTextField.isEnabled = service.changeGasLimitEnable
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: 0.33) {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }
    }

    @IBAction func dismiss() {
        UIView.animate(withDuration: 0.33, animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    @IBAction func confirm(_ sender: Any) {
        service.gasPrice = UInt(gasPriceTextField.text!) ?? 0
        service.gasLimit = UInt(gasLimitTextField.text!) ?? 0
        dismiss()
    }
}

extension TransactionGasPriceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
}
