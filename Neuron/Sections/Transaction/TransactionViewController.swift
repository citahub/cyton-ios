//
//  TransactionViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionViewController: UITableViewController {
    // Wallet
    @IBOutlet weak var walletIconView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!

    @IBOutlet weak var tokenBalanceButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var gasCostLabel: UILabel!

    @IBOutlet weak var addressTextField: UITextField!
    var token: TokenModel! {
        didSet {
            service = TransactionService.service(with: token)
        }
    }
    var service: TransactionService!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(token.symbol)转账"
        walletIconView.image = UIImage(data: service.wallet.iconData)
        walletNameLabel.text = service.wallet.name
        walletAddressLabel.text = service.wallet.address
        if service.tokenBalance == Double(Int(service.tokenBalance)) {
            tokenBalanceButton.setTitle(String(format: "%.0lf%@", service.tokenBalance, token.symbol), for: .normal)
        } else {
            tokenBalanceButton.setTitle(String(format: "%.8lf%@", service.tokenBalance, token.symbol), for: .normal)
        }
        gasCostLabel.text = String(format: "%.8lf%@", service.gasCost, token.symbol)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionConfirmViewController" {
            let controller = segue.destination as! TransactionConfirmViewController
            controller.service = service
        }
    }

    @IBAction func next(_ sender: Any) {
        let amountText = amountTextField.text ?? ""
        service.toAddress = addressTextField.text ?? ""
        service.amount = Double(amountText.hasPrefix(".") ? "0" + amountText : amountText) ?? 0.0
        if service.isEffectiveTransferInfo {
            performSegue(withIdentifier: "TransactionConfirmViewController", sender: nil)
        }
    }

    @IBAction func transactionAvailableBalance(_ sender: Any) {
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 2 && service.isSupportGasSetting ? true : false
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == 2 && service.isSupportGasSetting ? indexPath : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TransactionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
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
        }
        return true
    }
}
