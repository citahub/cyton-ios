//
//  ContractController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import Nervos
import BigInt
import struct BigInt.BigUInt
import web3swift

enum ChainType {
    case appChain
    case eth
}

protocol ContractControllerDelegate: class {
    func callBackWebView(id: Int, value: String, error: DAppError?)
}

class ContractController: UIViewController {
    var requestAddress: String = ""
    var dappCommonModel: DAppCommonModel!
    private var chainType: ChainType = .appChain
    private var tokenModel = TokenModel()
    var payCoverViewController: PayCoverViewController!
    weak var delegate: ContractControllerDelegate?

    lazy private var valueRightView: UILabel = {
        let valueRightView = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        valueRightView.font = UIFont.systemFont(ofSize: 14)
        valueRightView.textColor = ColorFromString(hex: "#989CAA")
        valueRightView.textAlignment = .center
        return valueRightView
    }()

    lazy private var gasRightView: UILabel = {
        let gasRightView = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        gasRightView.font = UIFont.systemFont(ofSize: 14)
        gasRightView.textColor = ColorFromString(hex: "#989CAA")
        gasRightView.textAlignment = .center
        return gasRightView
    }()

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var gasTextField: UITextField!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var dataTextView: UITextView!

    private var gasPrice = BigUInt()
    private var gasLimit = BigUInt()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合约调用"
        payCoverViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "confirmViewController") as? PayCoverViewController
        payCoverViewController.dappDelegate = self
        dealWithUI()
        setUIData()
    }

    func getTokenModel() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        appModel.nativeTokenList.forEach { (tokenModel) in
            switch chainType {
            case .appChain:
                if dappCommonModel.appChain!.chainId == Int(tokenModel.chainId) {
                    self.tokenModel = tokenModel
                }
            case .eth:
                if dappCommonModel.eth!.chainId == Int(tokenModel.chainId) {
                    self.tokenModel = tokenModel
                }
            }
        }
        gasRightView.text = tokenModel.symbol
        valueRightView.text = tokenModel.symbol
    }

    func setUIData() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        walletNameLabel.text = walletModel.name
        addressLabel.text = walletModel.address
        iconImage.image = UIImage(data: walletModel.iconData)

        requestTextField.text = requestAddress
        if dappCommonModel.chainType == "AppChain" {
            chainType = .appChain
            toTextField.text = dappCommonModel.appChain?.to
            valueTextField.text = formatScientValue(value: dappCommonModel.appChain?.value ?? "0x")
            gasTextField.text = getNervosTransactionCosted(with: BigUInt(dappCommonModel.appChain?.quota.clean ?? "1000000")!)
            dataTextView.text = dappCommonModel.appChain?.data
        } else {
            chainType = .eth
            toTextField.text = dappCommonModel.eth?.to
            valueTextField.text = formatScientValue(value: dappCommonModel.eth?.value ?? "0x")
            getETHGas(ethGasPirce: dappCommonModel.eth?.gasPrice?.clean, ethGasLimit: dappCommonModel.eth?.gasLimit?.clean)
            dataTextView.text = dappCommonModel.eth?.data

        }
        getTokenModel()
    }

    func dealWithUI() {
        tabbedButtonView.buttonTitles = ["HEX", "UTF8"]
        tabbedButtonView.delegate = self
        valueTextField.rightViewMode = .always
        valueTextField.rightView = valueRightView
        gasTextField.rightViewMode = .always
        gasTextField.rightView = gasRightView
    }

    func getNervosTransactionCosted(with quotaInput: BigUInt) -> String {
        return Web3Utils.formatToEthereumUnits(quotaInput, toUnits: .eth, decimals: 1, fallbackToScientific: true)!
    }

    func formatScientValue(value: String) -> String {
        let biguInt = BigUInt(atof(value))
        let format = Web3Utils.formatToEthereumUnits(biguInt, toUnits: .eth, decimals: 8, fallbackToScientific: false)!
        let finalValue = Double(format)!
        return finalValue.clean
    }

    func getETHGas(ethGasPirce: String?, ethGasLimit: String?) {
        Toast.showHUD()
        DispatchQueue.global().async {
            let web3 = Web3Network.getWeb3()
            if ethGasPirce != nil {
                self.gasPrice = BigUInt(ethGasPirce!)!
            } else {
                guard let gp = web3.eth.getGasPrice().value else {
                    self.gasPrice = BigUInt(8)
                    return
                }
                self.gasPrice = gp
            }

            if ethGasLimit != nil {
                self.gasLimit = BigUInt(ethGasLimit!) ?? BigUInt(100000)
            } else {
                var options = Web3Options.defaultOptions()
                options.gasLimit = self.gasLimit
                options.from = EthereumAddress(self.dappCommonModel.eth?.from ?? "")
                options.value = BigUInt(self.dappCommonModel.eth?.value ?? "0")
                let contract = web3.contract(Web3.Utils.coldWalletABI, at: EthereumAddress(self.dappCommonModel.eth?.to ?? ""))
                guard let estimatedGas = contract!.method(options: options)?.estimateGas(options: nil).value else {
                    self.gasLimit = BigUInt(100000)
                    return
                }
                self.gasLimit = estimatedGas
            }
            DispatchQueue.main.async {
                let gas = self.gasPrice * self.gasLimit
                self.gasTextField.text = Web3Utils.formatToEthereumUnits(gas, toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                Toast.hideHUD()
            }
        }
    }

    @IBAction func didClickRejectButton(_ sender: UIButton) {
        delegate?.callBackWebView(id: dappCommonModel.id, value: "", error: DAppError.cancelled)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didClickConfirmButton(_ sender: UIButton) {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        payCoverViewController.tokenModel = tokenModel
        payCoverViewController.walletAddress = walletModel.address
        payCoverViewController.gasCost = gasTextField.text ?? "0" + tokenModel.symbol
        payCoverViewController.amount = valueTextField.text ?? "0"
        payCoverViewController.dappCommonModel = dappCommonModel
        switch chainType {
        case .appChain:
            payCoverViewController.tokenType = .nervosToken
            payCoverViewController.toAddress = dappCommonModel.appChain?.to ?? ""
            payCoverViewController.extraData = Data.init(hex: dappCommonModel.appChain?.data ?? "")
            payCoverViewController.gasPrice = BigUInt(dappCommonModel.appChain?.quota.clean ?? "") ?? BigUInt(1000000)
        case .eth:
            payCoverViewController.tokenType = .ethereumToken
            payCoverViewController.toAddress = dappCommonModel.eth?.to ?? ""
            payCoverViewController.extraData = Data.init(hex: dappCommonModel.eth?.data ?? "")
            payCoverViewController.gasPrice = gasPrice
        }
        UIApplication.shared.keyWindow?.addSubview(payCoverViewController.view)
    }
}

extension ContractController: TabbedButtonsViewDelegate {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        var dataString: String
        switch chainType {
        case .appChain:
            dataString = dappCommonModel.appChain?.data ?? ""
        case .eth:
            dataString = dappCommonModel.eth?.data ?? ""
        }

        if index == 0 {
            dataTextView.text = dataString
        } else {
            dataTextView.text = String(decoding: Data.fromHex(dataString)!, as: UTF8.self)
        }
    }
}

extension ContractController: DAppPayCoverViewControllerDelegate {
    func dappTransactionResult(id: Int, value: String, error: DAppError?) {
        delegate?.callBackWebView(id: id, value: value, error: error)
        navigationController?.popViewController(animated: true)
    }
}
