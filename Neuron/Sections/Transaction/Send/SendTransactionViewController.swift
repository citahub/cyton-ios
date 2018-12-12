//
//  SendTransactionViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard
import BigInt
import AppChain
import RealmSwift

class SendTransactionViewController: UITableViewController, TransactonSender {
    @IBOutlet private weak var walletIconView: UIImageView!
    @IBOutlet private weak var walletNameLabel: UILabel!
    @IBOutlet private weak var walletAddressLabel: UILabel!
    @IBOutlet private weak var tokenBalanceButton: UIButton!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var gasCostLabel: UILabel!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenTitleLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var gasCostTitleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    var paramBuilder: TransactionParamBuilder!
    var enableSwitchToken = false
    private var observers = [NSKeyValueObservation]()

    private lazy var summaryPageItem: TxSummaryPageItem = {
        return TxSummaryPageItem.create()
    }()
    private lazy var bulletinManager: BLTNItemManager = {
        let passwordPageItem = createPasswordPageItem()
        summaryPageItem.next = passwordPageItem
        summaryPageItem.actionHandler = { item in
            item.manager?.displayNextItem()
        }

        return BLTNItemManager(rootItem: summaryPageItem)
    }()

    var tokenModel: TokenModel!
    var recipientAddress: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenTitleLabel.text = "Transaction.Send.txToken".localized()
        amountTitleLabel.text = "Transaction.Send.txAmount".localized()
        amountTextField.placeholder = "Transaction.Send.inputAmount".localized()
        addressTitleLabel.text = "Transaction.Send.receiptAddress".localized()
        addressTextField.placeholder = "Transaction.Send.receiptAddress".localized()
        gasCostTitleLabel.text = "Transaction.Send.gasFee".localized()
        nextButton.setTitle("Common.next".localized(), for: .normal)

        if enableSwitchToken && token == nil {
            tokenModel = AppModel.current.currentWallet?.selectedTokenList.first
        }

        createParamBuilder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "switchToken" {
            let controller = segue.destination as! TransactionSwitchTokenViewController
            controller.currentToken = tokenModel
            controller.delegate = self
        } else if segue.identifier == String(describing: TransactionGasCostViewController.self) {
            let controller = segue.destination as! TransactionGasCostViewController
            controller.param = paramBuilder
        }
    }

    @IBAction func next(_ sender: Any) {
        view.endEditing(true)

        paramBuilder.value = BigUInt.parseToBigUInt(amountTextField.text!, tokenModel.decimals)
        paramBuilder.to = addressTextField.text!

        if isEffectiveTransferInfo {
            summaryPageItem.update(paramBuilder)
            bulletinManager.showBulletin(above: self)
        }
    }

    @IBAction func scanQRCode() {
        UIApplication.shared.keyWindow?.endEditing(true)
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        navigationController?.pushViewController(qrCodeViewController, animated: true)
    }

    @IBAction func transactionAvailableBalance() {
        switch tokenModel.type {
        case .ether, .appChain:
            if paramBuilder.txFee > paramBuilder.tokenBalance {
                Toast.showToast(text: String(format: "Transaction.Send.balanceNotSufficient".localized(), tokenModel.gasSymbol))
                return
            }
            let amount = paramBuilder.tokenBalance - paramBuilder.txFee
            let amountText = amount.toDecimalNumber(tokenModel.decimals).formatterToString(8)
            amountTextField.text = amountText
        case .erc20:
            let realm = try! Realm()
            let ether = realm.objects(TokenModel.self).first(where: { $0.type == .ether })!
            if ether.balance < paramBuilder.txFee {
                Toast.showToast(text: String(format: "Transaction.Send.balanceNotSufficient".localized(), tokenModel.gasSymbol))
                return
            }
            amountTextField.text = tokenModel.balance.toDecimalNumber(tokenModel.decimals).formatterToString(8)
        default:
            break
        }
    }

    func setupUI() {
        let wallet = AppModel.current.currentWallet!
        title = String(format: "Transaction.Send.title".localized(), tokenModel.symbol)

        walletIconView.image = UIImage(data: wallet.iconData)
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address
        tokenBalanceButton.setTitle("\(tokenModel.balance.toAmountText(tokenModel.decimals)) \(tokenModel.symbol)", for: .normal)
        addressTextField.text = paramBuilder.to
        tokenLabel.text = tokenModel.symbol

        updateGasCost()
    }

    private func updateGasCost() {
        gasCostLabel.text = "\(paramBuilder.txFeeText) \(paramBuilder.nativeCoinSymbol)"
        if paramBuilder.tokenPrice > 0 {
            let amount = paramBuilder.txFee.toDecimalNumber().multiplying(by: NSDecimalNumber(value: paramBuilder.tokenPrice))
            gasCostLabel.text! += "≈ \(paramBuilder.currencySymbol) " + amount.formatterToString(2)
        }
    }

    private func createPasswordPageItem() -> PasswordPageItem {
        let passwordPageItem = PasswordPageItem.create()

        passwordPageItem.actionHandler = { [weak self] item in
            item.manager?.displayActivityIndicator()
            guard let self = self else {
                return
            }
            self.sendTransaction(password: passwordPageItem.passwordField.text!)
        }

        return passwordPageItem
    }
}

// MARK: - Send Transaction

private extension SendTransactionViewController {
    func sendTransaction(password: String) {
        DispatchQueue.global().async {
            do {
                let txHash: String
                if self.paramBuilder.tokenType == .ether || self.paramBuilder.tokenType == .erc20 {
                    txHash = try self.sendEthereumTransaction(password: password)
                } else {
                    txHash = try self.sendAppChainTransaction(password: password)
                }
                DispatchQueue.main.async {
                    // TODO: send back txHash?
                    let successPageItem = SuccessPageItem.create(title: "交易已发送")
                    successPageItem.actionHandler = { item in
                        self.track()
                        item.manager?.dismissBulletin(animated: true)
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.bulletinManager.push(item: successPageItem)
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.bulletinManager.hideActivityIndicator()
                    /// HACKHACKHACK: Possible a bug of BulletinBoard, but after hiding activity indicator
                    /// the previous page item's views stop responding to update. To get around that
                    /// create a new item. Note this would leave more than one password item in the stack.
                    let passwordPageItem = self.createPasswordPageItem()
                    self.bulletinManager.push(item: passwordPageItem)
                    passwordPageItem.errorMessage = error.localizedDescription
                }
            }
        }
    }

    var isEffectiveTransferInfo: Bool {
        guard Address.isValid(paramBuilder.to) && paramBuilder.to != "0x" else {
            Toast.showToast(text: "Transaction.Send.addressError".localized())
            return false
        }

        if tokenModel.type == .erc20 {
            let realm = try! Realm()
            let ether = realm.objects(TokenModel.self).first(where: { $0.type == .ether })!
            if ether.balance < paramBuilder.txFee {
                Toast.showToast(text: String(format: "Transaction.Send.balanceNotSufficient".localized(), tokenModel.gasSymbol))
                return false
            }
        }

        guard !paramBuilder.hasSufficientBalance else { return true }

        let alert = UIAlertController(title: "Transaction.Send.transactionAvailableBalance".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Common.confirm".localized(), style: .default, handler: { (_) in
            self.transactionAvailableBalance()
        }))
        alert.addAction(UIAlertAction(title: "Common.cancel".localized(), style: .destructive))
        present(alert, animated: true, completion: nil)
        return false
    }

    func track() {
        SensorsAnalytics.Track.transaction(
            chainType: paramBuilder.chainId,
            currencyType: paramBuilder.symbol,
            currencyNumber: Double(amountTextField.text ?? "0")!,
            receiveAddress: addressTextField.text ?? "",
            outcomeAddress: AppModel.current.currentWallet!.address,
            transactionType: .normal
        )
    }
}

extension SendTransactionViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        // TODO: validate qr code (address or other protocol)
        paramBuilder.to = codeResult
        addressTextField.text = codeResult
    }
}

// MARK: - Switch transaction token

extension SendTransactionViewController: TransactionSwitchTokenViewControllerDelegate {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if !enableSwitchToken {
                return 0.0
            } else {
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 0 || indexPath.row == 3
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if enableSwitchToken {
                cell.isHidden = false
            } else {
                cell.isHidden = true
            }
        } else {
            cell.isHidden = false
        }
    }

    func switchToken(switchToken: TransactionSwitchTokenViewController, didSwitchToToken token: TokenModel) {
        self.tokenModel = token
        tableView.reloadData()

        observers.forEach { (observe) in
            observe.invalidate()
        }
        observers.removeAll()

        createParamBuilder()
    }

    private func createParamBuilder() {
        paramBuilder = TransactionParamBuilder(token: tokenModel)
        observers.append(paramBuilder.observe(\.txFeeText, options: [.initial]) { (_, _) in
            self.updateGasCost()
        })
        observers.append(paramBuilder.observe(\.tokenPrice, options: [.initial]) { [weak self](_, _) in
            self?.updateGasCost()
        })
        paramBuilder.from = AppModel.current.currentWallet!.address
        if recipientAddress != nil {
            paramBuilder.to = recipientAddress
        }
        setupUI()
    }
}
