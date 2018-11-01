//
//  ContractController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import AppChain
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

class ContractController: UITableViewController {
    var requestAddress: String = ""
    var dappName: String = ""
    var dappCommonModel: DAppCommonModel!
    private var chainType: ChainType = .appChain
    private var tokenModel = TokenModel()
    var payCoverViewController: PayCoverViewController!
    weak var delegate: ContractControllerDelegate?

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var totlePayLabel: UILabel!
    @IBOutlet weak var dappNameLabel: UILabel!
    @IBOutlet weak var requestStringLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
//    @IBOutlet weak var gasTextField: UITextField!
//    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
//    @IBOutlet weak var dataTextView: UITextView!

    private var gasPrice = BigUInt()
    private var gasLimit = BigUInt()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "支付详情"
        payCoverViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "confirmViewController") as? PayCoverViewController
        payCoverViewController.dappDelegate = self
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
    }

    func setUIData() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        fromLabel.text = walletModel.address
        requestStringLabel.text = requestAddress
        dappNameLabel.text = dappName
        if dappCommonModel.chainType == "AppChain" {
            chainType = .appChain
            toLabel.text = dappCommonModel.appChain?.to
            valueLabel.text = formatScientValue(value: dappCommonModel.appChain?.value ?? "0")
            gasLabel.text = getNervosTransactionCosted(with: BigUInt(dappCommonModel.appChain?.quota.clean ?? "1000000")!)
//            dataTextView.text = dappCommonModel.appChain?.data
        } else {
            chainType = .eth
            toLabel.text = dappCommonModel.eth?.to
            valueLabel.text = formatScientValue(value: dappCommonModel.eth?.value ?? "0")
            getETHGas(ethGasPirce: dappCommonModel.eth?.gasPrice?.clean, ethGasLimit: dappCommonModel.eth?.gasLimit?.clean)
//            dataTextView.text = dappCommonModel.eth?.data
        }
        getTokenModel()
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
            let web3 = Web3Network().getWeb3()
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
                self.gasLimit = BigUInt(ethGasLimit!) ?? BigUInt(1000000)
            } else {
                var options = Web3Options.defaultOptions()
                options.gasLimit = self.gasLimit
                options.from = EthereumAddress(self.dappCommonModel.eth?.from ?? "")
                options.value = BigUInt(self.dappCommonModel.eth?.value ?? "0")
                let contract = web3.contract(Web3.Utils.coldWalletABI, at: EthereumAddress(self.dappCommonModel.eth?.to ?? ""))
                guard let estimatedGas = contract!.method(options: options)?.estimateGas(options: nil).value else {
                    self.gasLimit = BigUInt(1000000)
                    return
                }
                self.gasLimit = estimatedGas
            }
            DispatchQueue.main.async {
                let gas = self.gasPrice * self.gasLimit
                self.gasLabel.text = Web3Utils.formatToEthereumUnits(gas, toUnits: .eth, decimals: 8, fallbackToScientific: false)!
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
        payCoverViewController.gasCost = gasLabel.text ?? "0" + tokenModel.symbol
        payCoverViewController.amount = valueLabel.text ?? "0"
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
//            dataTextView.text = dataString
        } else {
//            dataTextView.text = String(decoding: Data.fromHex(dataString)!, as: UTF8.self)
        }
    }
}

extension ContractController: DAppPayCoverViewControllerDelegate {
    func dappTransactionResult(id: Int, value: String, error: DAppError?) {
        delegate?.callBackWebView(id: id, value: value, error: error)
        navigationController?.popViewController(animated: true)
    }
}
