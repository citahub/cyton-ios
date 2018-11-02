//
//  TransactionViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import web3swift

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
    var token: TokenModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        service = TransactionService.service(with: token)
        service.delegate = self
        DispatchQueue.global().async {
            self.service.requestGasCost()
        }
        setupUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionConfirmViewController" {
            let controller = segue.destination as! TransactionConfirmViewController
            controller.service = service
        } else if segue.identifier == "TransactionGasPriceViewController" {
            let controller = segue.destination as! TransactionGasPriceViewController
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

    @IBAction func scanQRCode() {
        let controller = QRCodeController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func transactionAvailableBalance() {
        let amount = service.tokenBalance - service.gasCost
        guard amount > 0 else {
            Toast.showToast(text: "请确保账户剩余\(token.symbol)高于矿工费用，以便顺利完成转账～")
            return
        }
        amountTextField.text = "\(amount)"
    }

    // MARK: - TransactionServiceDelegate
    func transactionCompletion(_ transactionService: TransactionService, result: TransactionService.Result) {
        Toast.hideHUD()
        switch result {
        case .error(let error):
            Toast.showToast(text: error.rawValue)
        default:
            Toast.showToast(text: "转账成功,请稍后刷新查看")
            navigationController?.popViewController(animated: true)
        }
    }

    func transactionGasCostChanged(_ transactionService: TransactionService) {
        gasCostLabel.text = String(format: "%.8lf%@", service.gasCost, token.symbol)
    }

    // MARK: - UI
    func setupUI() {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!
        title = "\(token.symbol)转账"
        walletIconView.image = UIImage(data: wallet.iconData)
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address
        if service.tokenBalance == Double(Int(service.tokenBalance)) {
            tokenBalanceButton.setTitle(String(format: "%.0lf%@", service.tokenBalance, token.symbol), for: .normal)
        } else {
            tokenBalanceButton.setTitle(String(format: "%.8lf%@", service.tokenBalance, token.symbol), for: .normal)
        }
        gasCostLabel.text = ""
    }
}

extension TransactionViewController {
    var isEffectiveTransferInfo: Bool {
        if service.toAddress.count != 40 && service.toAddress.count != 42 {
            Toast.showToast(text: "您的地址错误，请重新输入")
            return false
        } else if service.toAddress != service.toAddress.lowercased() {
            let eip55String = EthereumAddress.toChecksumAddress(service.toAddress) ?? ""
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

extension TransactionViewController: QRCodeControllerDelegate {
    func didBackQRCodeMessage(codeResult: String) {
        addressTextField.text = codeResult
    }
}

extension TransactionViewController {
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
