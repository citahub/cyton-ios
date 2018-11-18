//
//  SendTransactionViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import AppChain
import Web3swift
import EthereumAddress

class SendTransactionViewController: UITableViewController {
    @IBOutlet weak var walletIconView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var tokenBalanceButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var gasCostLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!

    private var paramBuilder: TransactionParamBuilder!
    private var observers = [NSKeyValueObservation]()
    var token: TokenModel!
    var confirmViewController: TransactionConfirmViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        paramBuilder = TransactionParamBuilder(token: token)
        observers.append(paramBuilder.observe(\.txFeeNatural, options: [.initial]) { (_, _) in
            self.updateGasCost()
        })
        paramBuilder.from = WalletRealmTool.getCurrentAppModel().currentWallet!.address

        setupUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionConfirmViewController" {
            let controller = segue.destination as! TransactionConfirmViewController
            controller.paramBuilder = paramBuilder
            confirmViewController = controller
        } else if segue.identifier == "TransactionGasPriceViewController" {
            let controller = segue.destination as! TransactionGasPriceViewController
            controller.param = paramBuilder
        }
    }

    // MARK: - Event
    @IBAction func next(_ sender: Any) {
        let amount = Double(amountTextField.text!) ?? 0.0
        paramBuilder.value = amount.toAmount(token.decimals)
        paramBuilder.to = addressTextField.text!

        if isEffectiveTransferInfo {
            performSegue(withIdentifier: "TransactionConfirmViewController", sender: nil)
        }
    }

    @IBAction func scanQRCode() {
        UIApplication.shared.keyWindow?.endEditing(true)
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        navigationController?.pushViewController(qrCodeViewController, animated: true)
    }

    @IBAction func transactionAvailableBalance() {
        // TODO: FIXME: erc20 token requires ETH balance for tx fee
        let amount = Double(token.tokenBalance)! - paramBuilder.txFeeNatural
        amountTextField.text = "\(amount)"
        paramBuilder.value = amount.toAmount(token.decimals)
        guard paramBuilder.hasSufficientBalance else {
            Toast.showToast(text: "请确保账户剩余\(token.gasSymbol)高于矿工费用，以便顺利完成转账～")
            return
        }
    }

    // TODO: tx sent
    /*
    func transactionCompletion(_ transactionService: TransactionParamBuilder, result: TransactionParamBuilder.Result) {
        switch result {
        case .error(let error):
            Toast.showToast(text: error.localizedDescription)
        default:
            Toast.showToast(text: "转账成功,请稍后刷新查看")
            confirmViewController?.dismiss()
            navigationController?.popViewController(animated: true)

            SensorsAnalytics.Track.transaction(
                chainType: token.chainId,
                currencyType: token.symbol,
                currencyNumber: Double(amountTextField.text ?? "0")!,
                receiveAddress: addressTextField.text ?? "",
                outcomeAddress: WalletRealmTool.getCurrentAppModel().currentWallet!.address,
                transactionType: .normal
            )
        }
    }*/

    // MARK: - UI
    func setupUI() {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!
        title = "\(token.symbol)转账"
        walletIconView.image = UIImage(data: wallet.iconData)
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address
        tokenBalanceButton.setTitle("\(token.tokenBalance)\(token.symbol)", for: .normal)
        updateGasCost()
    }

    private func updateGasCost() {
        gasCostLabel.text = "\(paramBuilder.txFeeNatural.decimal)\(paramBuilder.nativeCoinSymbol)"
    }
}

extension SendTransactionViewController {
    var isEffectiveTransferInfo: Bool {
        guard Address.isValid(paramBuilder.to) && paramBuilder.to != "0x" else {
            Toast.showToast(text: "您的地址错误，请重新输入")
            return false
        }

        // TODO: FIXME: erc20 requires eth balance as tx fee
        if paramBuilder.hasSufficientBalance {
            return true
        }

        if paramBuilder.tokenBalance <= BigUInt(0) {
            Toast.showToast(text: "请确保账户剩余\(token.gasSymbol)高于矿工费用，以便顺利完成转账～")
            return false
        }
        let alert = UIAlertController(title: "您输入的金额超过您的余额，是否全部转出？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (_) in
            self.transactionAvailableBalance()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (_) in
            self.amountTextField.text = ""
        }))
        present(alert, animated: true, completion: nil)
        return false
    }
}

extension SendTransactionViewController: UITextFieldDelegate {
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

extension SendTransactionViewController: QRCodeViewControllerDelegate {
    func didBackQRCodeMessage(codeResult: String) {
        addressTextField.text = codeResult
    }
}

extension SendTransactionViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 2
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == 2 ? indexPath : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section == 0 && indexPath.row == 2 {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
}
