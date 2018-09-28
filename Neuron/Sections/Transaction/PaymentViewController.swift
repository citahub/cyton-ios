//
//  PaymentViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import IQKeyboardManagerSwift

class PaymentViewController: UITableViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var switchButton: UISwitch!
    private var gasPageViewController: UIPageViewController!
    private var simpleGasViewController: SimpleGasViewController!
    private var ethGasViewController: EthGasViewController!
    private var nervosQuoteViewController: NervosQuoteViewController!
    var payCoverViewController: PayCoverViewController!
    var tokenType: TokenType = .nervosToken
    var tokenModel = TokenModel()
    var ethGasPrice: BigUInt!
    var payValue: String = ""
    var destinationAddress: String = ""
    var extraData = Data()
    var nervosQuota: BigUInt!
    var gasCost: String = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "转账"
        amountTextField.delegate = self
        addressTextField.delegate = self
        simpleGasViewController = storyboard!.instantiateViewController(withIdentifier: "simpleGasViewController") as? SimpleGasViewController
        simpleGasViewController.delegate = self
        simpleGasViewController.tokenModel = tokenModel
        simpleGasViewController.tokenType = tokenType
        ethGasViewController = storyboard!.instantiateViewController(withIdentifier: "ethGasViewController") as? EthGasViewController
        ethGasViewController.delegate = self
        nervosQuoteViewController = storyboard!.instantiateViewController(withIdentifier: "nervosQuoteViewController") as? NervosQuoteViewController
        nervosQuoteViewController.delegate = self
        payCoverViewController = storyboard!.instantiateViewController(withIdentifier: "confirmViewController") as? PayCoverViewController
        payCoverViewController.delegate = self
        nervosQuoteViewController.tokenModel = tokenModel
        gasPageViewController.setViewControllers([simpleGasViewController], direction: .forward, animated: false)
        getBaseData()
    }

    func getBaseData() {
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        iconImageView.image = UIImage(data: walletModel.iconData)
        nameLabel.text = walletModel.name
        addressLabel.text = walletModel.address
        assetTypeLabel.text = tokenModel.symbol
        balanceLabel.text = tokenModel.tokenBalance + tokenModel.symbol
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gasPageViewController" {
            gasPageViewController = segue.destination as? UIPageViewController
        }
    }

    @IBAction func advancedSettingAction(_ sender: UISwitch) {
        if sender.isOn {
            switch tokenType {
            case .nervosToken:
                gasPageViewController.setViewControllers([nervosQuoteViewController], direction: .forward, animated: false)
            default:
                gasPageViewController.setViewControllers([ethGasViewController], direction: .forward, animated: false)
            }
        } else {
            gasPageViewController.setViewControllers([simpleGasViewController], direction: .forward, animated: false)
        }
    }

    @IBAction func clickQRButton(_ sender: UIButton) {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    @IBAction func clickNextButton(_ sender: UIButton) {
        if canProceedNextStep() {
            let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
            payCoverViewController.tokenModel = tokenModel
            payCoverViewController.walletAddress = walletModel.address
            payCoverViewController.amount = payValue
            payCoverViewController.toAddress = destinationAddress
            payCoverViewController.gasCost = gasCost
            payCoverViewController.tokenType = tokenType
            switch tokenType {
            case .ethereumToken:
                payCoverViewController.extraData = extraData
                payCoverViewController.gasPrice = ethGasPrice
            case .nervosToken:
                payCoverViewController.extraData = extraData
                payCoverViewController.gasPrice = nervosQuota
                payCoverViewController.gasCost = "1e-16 \(tokenModel.symbol)"
            case .erc20Token:
                payCoverViewController.gasPrice = ethGasPrice
                payCoverViewController.contrackAddress = tokenModel.address
            }
            UIApplication.shared.keyWindow?.addSubview(payCoverViewController.view)
        }
    }

    private func canProceedNextStep() -> Bool {
        if payValue.count == 0 {
            NeuLoad.showToast(text: "转账金额不能为空")
            return false
        }
        if destinationAddress.count == 0 {
            NeuLoad.showToast(text: "转账地址不能为空")
            return false
        }
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        if destinationAddress == walletModel.address {
            NeuLoad.showToast(text: "发送地址和收款地址不能相同")
            return false
        }
        let planPay = Double(payValue)!
        let tokenBalance = Double(tokenModel.tokenBalance)!
        if planPay > tokenBalance {
            NeuLoad.showToast(text: "余额不足")
            return false
        }
        if !destinationAddress.hasPrefix("0x") || destinationAddress.count != 42 {
            NeuLoad.showToast(text: "地址有误:地址一般为0x开头的42位字符")
            return false
        }
        return true
    }
}

extension PaymentViewController: SimpleGasViewControllerDelegate, QRCodeControllerDelegate, EthGasViewControllerDelegate, NervosQuoteViewControllerDelegate, UITextFieldDelegate, PayCoverViewControllerDelegate {
    func popToRootView() {
        navigationController?.popViewController(animated: true)
    }

    func getTransactionCostGas(gas: String) {
        gasCost = gas
    }

    func getNervosTransactionQuota(nervosQuoteViewController: NervosQuoteViewController, quota: BigUInt, data: Data) {
        nervosQuota = quota
        extraData = data
    }

    func getTransactionGasPriceAndData(ethGasViewController: EthGasViewController, gasPrice: BigUInt, data: Data) {
        ethGasPrice = gasPrice
        extraData = data
    }

    func getTransactionGasPrice(simpleGasViewController: SimpleGasViewController, gasPrice: BigUInt) {
        if tokenType == .nervosToken {
            nervosQuota = gasPrice
        } else {
            ethGasPrice = gasPrice
        }
    }

    func didBackQRCodeMessage(codeResult: String) {
        addressTextField.text = codeResult
        destinationAddress = codeResult
    }

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
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == amountTextField {
            payValue = textField.text ?? ""
        } else {
            destinationAddress = textField.text ?? ""
        }
    }
}
