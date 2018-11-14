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
import Web3swift
import EthereumAddress

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
    var advancedViewController: AdvancedViewController!
    weak var delegate: ContractControllerDelegate?
    var confirmViewController: TransactionConfirmViewController?

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
        getTokenModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdvancedViewController" {
            advancedViewController = segue.destination as? AdvancedViewController
            advancedViewController.delegate = self
            advancedViewController.dataString = dappCommonModel.eth?.data ?? ""
            advancedViewController.gasLimit = gasLimit
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AdvancedViewController" {
            return false
        }
        return true
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
            valueLabel.text = value
            gasLabel.text = getNervosTransactionCosted(with: appChainQuota) + tokenModel.symbol
            totlePayLabel.text = getTotleValue(value: dappCommonModel.appChain?.value ?? "0", gas: appChainQuota) + tokenModel.symbol
        } else {
            chainType = .eth
            toLabel.text = dappCommonModel.eth?.to
            value = formatScientValue(value: dappCommonModel.eth?.value ?? "0")
            valueLabel.text = value
            getETHGas(ethGasPirce: dappCommonModel.eth?.gasPrice?.clean, ethGasLimit: dappCommonModel.eth?.gasLimit?.clean)
        }
        formatValueLabel(value: value)
    }

    func formatValueLabel(value: String) {
        let range = NSMakeRange(valueLabel.text!.lengthOfBytes(using: .utf8), tokenModel.symbol.lengthOfBytes(using: .utf8))
        valueLabel.text! += tokenModel.symbol
        let attributedText = NSMutableAttributedString(attributedString: valueLabel.attributedText!)
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], range: range)
        valueLabel.attributedText = attributedText
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
            let web3 = EthereumNetwork().getWeb3()
            if ethGasPirce != nil {
                self.gasPrice = BigUInt(ethGasPirce!)!
            } else {
                do {
                    let gasPrice = try web3.eth.getGasPrice()
                    self.gasPrice = gasPrice
                } catch {
                    self.gasPrice = BigUInt(8)
                }
            }

            if ethGasLimit != nil {
                self.gasLimit = BigUInt(ethGasLimit!) ?? BigUInt(1000000)
            } else {
                var options = TransactionOptions()
                options.gasLimit = .limited(self.gasLimit)
                options.from = EthereumAddress(self.dappCommonModel.eth?.from ?? "")
                options.value = BigUInt(self.dappCommonModel.eth?.value ?? "0")
                let contract = web3.contract(Web3.Utils.coldWalletABI, at: EthereumAddress(self.dappCommonModel.eth?.to ?? ""))!
                if let estimatedGas = try? contract.method(transactionOptions: options)!.estimateGas(transactionOptions: nil) {
                    self.gasLimit = estimatedGas
                } else {
                    self.gasLimit = BigUInt(1000000)
                }
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            if dappCommonModel.chainType == "ETH" {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dappCommonModel.chainType == "ETH" && indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "AdvancedViewController", sender: indexPath.row)
        }
    }

    @IBAction func clickBackButton(_ sender: UIButton) {
        delegate?.callBackWebView(id: dappCommonModel.id, value: "", error: DAppError.userCanceled)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didClickConfirmButton(_ sender: UIButton) {
        let paramBuilder = TransactionParamBuilder(token: tokenModel)
        paramBuilder.from = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        // TODO: set input amount
        // paramBuilder.amount = Double(value) ?? 0.0

        switch chainType {
        case .appChain:
            paramBuilder.gasLimit = 10000000
            paramBuilder.to = dappCommonModel.appChain?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.appChain?.data ?? "")
            // TODO: set gas price
            // paramBuilder.gasPrice = BigUInt(dappCommonModel.appChain?.quota.clean ?? "")?.words.first ?? 1000000
        case .eth:
            paramBuilder.gasLimit = UInt64(gasLimit.words.first!)
            paramBuilder.to = dappCommonModel.eth?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.eth?.data ?? "")
            // TODO: set gas price
            // paramBuilder.gasPrice = gasPrice.words.first!
        }
        let controller: TransactionConfirmViewController = UIStoryboard(name: .transaction).instantiateViewController()
        controller.modalPresentationStyle = .overCurrentContext
        controller.paramBuilder = paramBuilder
        present(controller, animated: false, completion: nil)
        confirmViewController = controller
    }
}

// TODO: tx sent
extension ContractController {
    /*
    func transactionCompletion(_ transactionService: TransactionParamBuilder, result: TransactionParamBuilder.Result) {
        switch result {
        case .error:
            delegate?.callBackWebView(id: dappCommonModel.id, value: "", error: DAppError.sendTransactionFailed)
        case .succee(let txhash):
            SensorsAnalytics.Track.transaction(
                chainType: tokenModel.chainId,
                currencyType: tokenModel.symbol,
                currencyNumber: Double(value) ?? 0.0,
                receiveAddress: dappCommonModel.appChain?.to ?? "",
                outcomeAddress: WalletRealmTool.getCurrentAppModel().currentWallet!.address,
                transactionType: .normal
            )
            delegate?.callBackWebView(id: dappCommonModel.id, value: txhash.addHexPrefix(), error: nil)
        }
        confirmViewController?.dismiss()
        navigationController?.popViewController(animated: true)
    }*/
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
