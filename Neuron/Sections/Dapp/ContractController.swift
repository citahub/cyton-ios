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
    var advancedViewController: AdvancedViewController!
    weak var delegate: ContractControllerDelegate?

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var totlePayLabel: UILabel!
    @IBOutlet weak var dappNameLabel: UILabel!
    @IBOutlet weak var requestStringLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!

    private var gasPrice = BigUInt()
    private var gasLimit = BigUInt()
    private var ethereumGas: String?
    private var value: String! // both appChain'amount and Ethereum'amount

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "支付详情"
        payCoverViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "confirmViewController") as? PayCoverViewController
        payCoverViewController.dappDelegate = self
        advancedViewController = storyboard!.instantiateViewController(withIdentifier: "advancedViewController") as? AdvancedViewController
        advancedViewController.delegate = self
        getTokenModel()
    }

    func getTokenModel() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        appModel.nativeTokenList.forEach { (tokenModel) in
            if dappCommonModel.chainType == "AppChain" {
                if dappCommonModel.appChain!.chainId == Int(tokenModel.chainId) {
                    self.tokenModel = tokenModel
                }
            } else {
                if dappCommonModel.eth!.chainId == Int(tokenModel.chainId) {
                    self.tokenModel = tokenModel
                }
            }
        }
        setUIData()
    }

    func setUIData() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        fromLabel.text = walletModel.address
        requestStringLabel.text = requestAddress
        dappNameLabel.text = dappName

        if dappCommonModel.chainType == "AppChain" {
            let appChainQuota = BigUInt(dappCommonModel.appChain?.quota.clean ?? "1000000")!
            chainType = .appChain
            toLabel.text = dappCommonModel.appChain?.to
            value = formatScientValue(value: dappCommonModel.appChain?.value ?? "0")
            valueLabel.text = value + tokenModel.symbol
            gasLabel.text = getNervosTransactionCosted(with: appChainQuota) + tokenModel.symbol
            totlePayLabel.text = getTotleValue(value: dappCommonModel.appChain?.value ?? "0", gas: appChainQuota) + tokenModel.symbol
        } else {
            chainType = .eth
            toLabel.text = dappCommonModel.eth?.to
            value = formatScientValue(value: dappCommonModel.eth?.value ?? "0")
            valueLabel.text = value + tokenModel.symbol
            getETHGas(ethGasPirce: dappCommonModel.eth?.gasPrice?.clean, ethGasLimit: dappCommonModel.eth?.gasLimit?.clean)
        }
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

    // gas is equal to appChain's quota
    func getTotleValue(value: String, gas: BigUInt) -> String {
        let biguInt = BigUInt(atof(value))
        let finalValue = biguInt + gas
        let formatValue = Web3Utils.formatToEthereumUnits(finalValue, toUnits: .eth, decimals: 8, fallbackToScientific: true)!
        let finalCost = Double(formatValue)!
        return finalCost.clean
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
                self.ethereumGas = Web3Utils.formatToEthereumUnits(gas, toUnits: .eth, decimals: 8, fallbackToScientific: false)
                self.gasLabel.text = Double(self.ethereumGas!)!.clean + self.tokenModel.symbol
                let bigUIntValue = Web3Utils.parseToBigUInt(self.value, units: .eth)!
                self.totlePayLabel.text =  self.getTotleValue(value: bigUIntValue.description, gas: gas) + self.tokenModel.symbol
                Toast.hideHUD()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dappCommonModel.chainType == "ETH" {
            advancedViewController.dataString = dappCommonModel.eth?.data ?? ""
            advancedViewController.gasLimit = gasLimit
            UIApplication.shared.keyWindow?.addSubview(advancedViewController.view)
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
        payCoverViewController.amount = value
        payCoverViewController.gasCost = gasLabel.text ?? "0"
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

extension ContractController: DAppPayCoverViewControllerDelegate {
    func dappTransactionResult(id: Int, value: String, error: DAppError?) {
        delegate?.callBackWebView(id: id, value: value, error: error)
        navigationController?.popViewController(animated: true)
    }
}

extension ContractController: AdvancedViewControllerDelegate {
    func getCustomGas(gasPrice: BigUInt, gas: BigUInt) {
        self.gasPrice = gasPrice
        ethereumGas = Web3Utils.formatToEthereumUnits(gas, toUnits: .eth, decimals: 8, fallbackToScientific: true) ?? "0"
        let bigUIntValue = Web3Utils.parseToBigUInt(value, units: .eth)!
        let totlePay = getTotleValue(value: bigUIntValue.description, gas: gas)
        totlePayLabel.text = totlePay + tokenModel.symbol
        gasLabel.text = Double(ethereumGas ?? "")!.clean + tokenModel.symbol
    }
}
