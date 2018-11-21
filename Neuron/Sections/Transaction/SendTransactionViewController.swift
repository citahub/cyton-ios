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
import Web3swift
import EthereumAddress

protocol TransactonSender {
    var paramBuilder: TransactionParamBuilder! { get set }
    func sendEthereumTransaction(password: String) throws -> TxHash
    func sendAppChainTransaction(password: String) throws -> TxHash
}

extension TransactonSender {
    func sendEthereumTransaction(password: String) throws -> TxHash {
        let keystore = WalletManager.default.keystore(for: paramBuilder.from)
        let web3 = EthereumNetwork().getWeb3()
        web3.addKeystoreManager(KeystoreManager([keystore]))

        if paramBuilder.tokenType == .ether {
            let sender = try EthereumTxSender(web3: web3, from: paramBuilder.from)
            return try sender.sendETH(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                data: paramBuilder.data,
                password: password
            )
        } else {
            let sender = try EthereumTxSender(web3: web3, from: paramBuilder.from)
            // TODO: estimate gas
            return try sender.sendToken(
                to: paramBuilder.to,
                value: paramBuilder.value,
                gasLimit: paramBuilder.gasLimit,
                gasPrice: BigUInt(paramBuilder.gasPrice),
                contractAddress: paramBuilder.contractAddress,
                password: password
            )
        }
    }

    func sendAppChainTransaction(password: String) throws -> TxHash {
        let appChain: AppChain
        if paramBuilder.rpcNode.isEmpty {
            appChain = AppChainNetwork.appChain()
        } else {
            guard let appChainUrl = URL(string: paramBuilder.rpcNode) else {
                throw SendTransactionError.invalidAppChainNode
            }
            appChain = AppChainNetwork.appChain(url: appChainUrl)
        }
        if paramBuilder.tokenType == .appChain {
            let sender = try AppChainTxSender(
                appChain: appChain,
                walletManager: WalletManager.default,
                from: paramBuilder.from
            )
            return try sender.send(
                to: paramBuilder.to,
                value: paramBuilder.value,
                quota: paramBuilder.gasLimit,
                data: paramBuilder.data,
                chainId: BigUInt(paramBuilder.chainId)!,
                password: password
            )
        } else {
            return "" // TODO: AppChainErc20 not implemented yet.
        }
    }
}

class SendTransactionViewController: UITableViewController, TransactonSender {
    @IBOutlet private weak var walletIconView: UIImageView!
    @IBOutlet private weak var walletNameLabel: UILabel!
    @IBOutlet private weak var walletAddressLabel: UILabel!
    @IBOutlet private weak var tokenBalanceButton: UIButton!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var gasCostLabel: UILabel!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet weak var tokenLabel: UILabel!

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

    var token: TokenModel!
    var recipientAddress: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        if enableSwitchToken && token == nil {
            token = WalletRealmTool.getCurrentAppModel().nativeTokenList.first
        }

        paramBuilder = TransactionParamBuilder(token: token)
        observers.append(paramBuilder.observe(\.txFeeNatural, options: [.initial]) { (_, _) in
            self.updateGasCost()
        })
        paramBuilder.from = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        if recipientAddress != nil {
            paramBuilder.to = recipientAddress
        }
        setupUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionGasPriceViewController" {
            let controller = segue.destination as! TransactionGasPriceViewController
            controller.param = paramBuilder
        } else if segue.identifier == "switchToken" {
            let controller = segue.destination as! TransactionSwitchTokenViewController
            controller.currentToken = token
            controller.delegate = self
        }
    }

    @IBAction func next(_ sender: Any) {
        view.endEditing(true)

        let amount = Double(amountTextField.text!) ?? 0.0
        paramBuilder.value = amount.toAmount(token.decimals)
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
        // TODO: FIXME: erc20 token requires ETH balance for tx fee
        let amount = Double(token.tokenBalance)! - paramBuilder.txFeeNatural
        amountTextField.text = "\(amount)"
        paramBuilder.value = amount.toAmount(token.decimals)
        guard paramBuilder.hasSufficientBalance else {
            Toast.showToast(text: "请确保账户剩余\(token.gasSymbol)高于矿工费用，以便顺利完成转账～")
            return
        }
    }

    func setupUI() {
        let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!
        title = "\(token.symbol)转账"
        walletIconView.image = UIImage(data: wallet.iconData)
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address
        tokenBalanceButton.setTitle("\(token.tokenBalance)\(token.symbol)", for: .normal)
        addressTextField.text = paramBuilder.to
        tokenLabel.text = token.symbol

        updateGasCost()
    }

    private func updateGasCost() {
        gasCostLabel.text = "\(paramBuilder.txFeeNatural.decimal) \(paramBuilder.nativeCoinSymbol)"
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
                let txHash: TxHash
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

    func track() {
        SensorsAnalytics.Track.transaction(
            chainType: paramBuilder.chainId,
            currencyType: paramBuilder.symbol,
            currencyNumber: Double(amountTextField.text ?? "0")!,
            receiveAddress: addressTextField.text ?? "",
            outcomeAddress: WalletRealmTool.getCurrentAppModel().currentWallet!.address,
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
        self.token = token

        observers.forEach { (observe) in
            observe.invalidate()
        }
        observers.removeAll()

        paramBuilder = TransactionParamBuilder(token: token)
        observers.append(paramBuilder.observe(\.txFeeNatural, options: [.initial]) { (_, _) in
            self.updateGasCost()
        })
        paramBuilder.from = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        if recipientAddress != nil {
            paramBuilder.to = recipientAddress
        }
        setupUI()
    }
}
