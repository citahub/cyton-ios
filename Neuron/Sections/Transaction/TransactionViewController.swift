//
//  TransactionViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import TrustCore

class TransactionViewController: UITableViewController, TransactionServiceDelegate {
    // Wallet
    @IBOutlet weak var walletIconView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var tokenBalanceButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var gasCostLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    var service: TransactionService!
    var token: TokenModel! {
        didSet {
            service = TransactionService.service(with: token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerEventStrategy(with: TransactionConfirmSendViewController.Event.confirm.rawValue, action: #selector(TransactionViewController.confirmSend(userInfo:)))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionConfirmViewController" {
            let controller = segue.destination as! TransactionConfirmViewController
            controller.service = service
        }
    }

    // MARK: - Event
    @IBAction func next(_ sender: Any) {
        let amountText = amountTextField.text ?? ""
        service.toAddress = addressTextField.text ?? ""
        service.amount = Double(amountText.hasPrefix(".") ? "0" + amountText : amountText) ?? 0.0
        if isEffectiveTransferInfo {
            performSegue(withIdentifier: "TransactionConfirmViewController", sender: nil)
        }
    }

    @objc func confirmSend(userInfo: [String: String]) {
        let password = userInfo["password"] ?? ""
        if password.lengthOfBytes(using: .utf8) < 8 {
            Toast.showToast(text: "请输入有效的钱包密码")
            return
        }
        service.password = password
        service.sendTransaction()
    }

    @IBAction func transactionAvailableBalance() {
        amountTextField.text = "\(service.tokenBalance - service.gasCost)"
    }

    // MARK: - TransactionServiceDelegate
    func transactionCompletion(_ transactionService: TransactionService) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: -
    func setupUI() {
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
}

extension TransactionViewController {
    var isEffectiveTransferInfo: Bool {
        if service.toAddress.count != 40 && service.toAddress.count != 42 {
            Toast.showToast(text: "您的地址错误，请重新输入")
            return false
        } else if service.toAddress != service.toAddress.lowercased() {
            let eip55String = TrustCore.EthereumAddress(string: service.toAddress)?.eip55String ?? ""
            if eip55String != service.toAddress {
                Toast.showToast(text: "您的地址错误，请重新输入")
                return false
            }
        } else if service.amount > service.tokenBalance - service.gasCost {
            let alert = UIAlertController(title: "您输入的金额超过您的余额，是否全部转出？", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (_) in
                self.transactionAvailableBalance()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (_) in
                self.amountTextField.text = ""
            }))
            return false
        }
        return true
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

extension TransactionViewController {
    // MARK: - TableView Delegate
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
