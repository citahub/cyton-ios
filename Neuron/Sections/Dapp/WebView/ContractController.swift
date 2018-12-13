//
//  ContractController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BLTNBoard
import AppChain
import BigInt
import Web3swift
import EthereumAddress

enum ChainType {
    case appChain
    case eth
}

protocol ContractControllerDelegate: class {
    func callBackWebView(id: Int, value: String, error: DAppError?)
}

class ContractController: UITableViewController, TransactonSender {
    var requestAddress: String = ""
    var dappName: String = ""
    var dappCommonModel: DAppCommonModel!
    var paramBuilder: TransactionParamBuilder!
    private var chainType: ChainType = .appChain
    var tokenModel: TokenModel! {
        didSet {
            paramBuilder = TransactionParamBuilder(token: tokenModel)
        }
    }
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
        let wallet = AppModel.current.currentWallet
        wallet?.tokenModelList.forEach { (tokenModel) in
            if dappCommonModel.chainType == "AppChain" {
                if dappCommonModel.appChain!.chainId == Int(tokenModel.chain!.chainId) && tokenModel.isNativeToken {
                    self.tokenModel = tokenModel
                }
            } else {
                if dappCommonModel.eth!.chainId == -1 && tokenModel.isNativeToken {
                    self.tokenModel = tokenModel
                }
            }
        }
        setUIData()
    }

    func setUIData() {
        let walletModel = AppModel.current.currentWallet!
        fromLabel.text = walletModel.address
        requestStringLabel.text = requestAddress
        dappNameLabel.text = dappName

        if dappCommonModel.chainType == "AppChain" {
            let appChainQuota = dappCommonModel.appChain?.quota!.toBigUInt() ?? 0
            chainType = .appChain
            toLabel.text = dappCommonModel.appChain?.to
            value = formatScientValue(value: dappCommonModel.appChain?.value?.toBigUInt() ?? 0)
            valueLabel.text = value
            gasLabel.text = getNervosTransactionCosted(with: appChainQuota) + tokenModel.symbol
            totlePayLabel.text = getTotleValue(value: dappCommonModel.appChain?.value?.toBigUInt() ?? 0, gas: appChainQuota) + tokenModel.symbol
        } else {
            chainType = .eth
            toLabel.text = dappCommonModel.eth?.to
            value = formatScientValue(value: dappCommonModel.eth?.value?.toBigUInt() ?? "0")
            valueLabel.text = value
            getETHGas(ethGasPirce: dappCommonModel.eth?.gasPrice, ethGasLimit: dappCommonModel.eth?.gasLimit)
        }
        formatValueLabel(value: value)
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

    func formatValueLabel(value: String) {
        let range = NSRange(location: valueLabel.text!.lengthOfBytes(using: .utf8), length: tokenModel.symbol.lengthOfBytes(using: .utf8) + 1)
        valueLabel.text! += " " + tokenModel.symbol
        let attributedText = NSMutableAttributedString(attributedString: valueLabel.attributedText!)
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], range: range)
        valueLabel.attributedText = attributedText
    }

    func getNervosTransactionCosted(with quotaInput: BigUInt) -> String {
        return Web3Utils.formatToEthereumUnits(quotaInput, toUnits: .eth, decimals: 1, fallbackToScientific: true)!
    }

    func formatScientValue(value: BigUInt) -> String {
        let format = Web3Utils.formatToEthereumUnits(value, toUnits: .eth, decimals: 8, fallbackToScientific: false)!
        let finalValue = Double(format)!
        return finalValue.trailingZerosTrimmed
    }

    // gas is equal to appChain's quota
    func getTotleValue(value: BigUInt, gas: BigUInt) -> String {
        let finalValue = value + gas
        let formatValue = Web3Utils.formatToEthereumUnits(finalValue, toUnits: .eth, decimals: 8, fallbackToScientific: true)!
        return Double(formatValue)!.trailingZerosTrimmed
    }

    func getETHGas(ethGasPirce: String?, ethGasLimit: String?) {
        Toast.showHUD()
        DispatchQueue.global().async {
            let web3 = EthereumNetwork().getWeb3()
            if ethGasPirce != nil {
                self.gasPrice = ethGasLimit!.toBigUInt()!
            } else {
                do {
                    let gasPrice = try web3.eth.getGasPrice()
                    self.gasPrice = gasPrice
                } catch {
                    self.gasPrice = BigUInt(0)
                }
            }

            if ethGasLimit != nil {
                self.gasLimit = ethGasLimit!.toBigUInt()!
            } else {
                var options = TransactionOptions()
                options.gasLimit = .limited(self.gasLimit)
                options.from = EthereumAddress(self.dappCommonModel.eth?.from ?? "")
                options.value = self.dappCommonModel.eth?.value?.toBigUInt()
                let contract = web3.contract(Web3.Utils.coldWalletABI, at: EthereumAddress(self.dappCommonModel.eth?.to ?? ""))!
                if let estimatedGas = try? contract.method(transactionOptions: options)!.estimateGas(transactionOptions: options) {
                    self.gasLimit = estimatedGas * 4
                } else {
                    self.gasLimit = BigUInt(0)
                }
            }
            DispatchQueue.main.async {
                let gas = self.gasPrice * self.gasLimit
                self.ethereumGas = Web3Utils.formatToEthereumUnits(gas, toUnits: .eth, decimals: 8, fallbackToScientific: false)
                self.gasLabel.text = Double(self.ethereumGas!)!.trailingZerosTrimmed + self.tokenModel.symbol
                self.totlePayLabel.text =  self.getTotleValue(value: self.dappCommonModel.eth?.value?.toBigUInt() ?? 0, gas: gas) + self.tokenModel.symbol
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
        guard let paramBuilder = paramBuilder else {
            return
        }
        paramBuilder.from = AppModel.current.currentWallet!.address
        paramBuilder.value = BigUInt.parseToBigUInt(value, tokenModel.decimals)

        switch chainType {
        case .appChain:
            paramBuilder.gasLimit = 10000000
            paramBuilder.gasPrice = dappCommonModel.appChain?.quota?.toBigUInt() ?? 1000000
            paramBuilder.to = dappCommonModel.appChain?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.appChain?.data ?? "")
        case .eth:
            paramBuilder.gasLimit = UInt64(gasLimit)
            paramBuilder.gasPrice = gasPrice
            paramBuilder.to = dappCommonModel.eth?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.eth?.data ?? "")
        }

        summaryPageItem.update(paramBuilder)
        bulletinManager.showBulletin(above: self)
    }
}

private extension ContractController {
    func sendTransaction(password: String) {
        guard let paramBuilder = paramBuilder else {
            return
        }
        DispatchQueue.global().async {
            do {
                let txHash: TxHash
                if paramBuilder.tokenType == .ether || paramBuilder.tokenType == .erc20 {
                    txHash = try self.sendEthereumTransaction(password: password)
                } else {
                    txHash = try self.sendAppChainTransaction(password: password)
                }

                DispatchQueue.main.async {
                    let successPageItem = SuccessPageItem.create(title: "DApp.Contract.TransactionSend".localized())
                    successPageItem.actionHandler = { item in
                        self.transactionDidSend(txhash: txHash)
                    }
                    self.bulletinManager.push(item: successPageItem)
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.bulletinManager.hideActivityIndicator()
                    let passwordPageItem = self.createPasswordPageItem()
                    self.bulletinManager.push(item: passwordPageItem)
                    passwordPageItem.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func transactionDidSend(txhash: TxHash?) {
        if let txhash = txhash {
            delegate?.callBackWebView(id: dappCommonModel.id, value: txhash.addHexPrefix(), error: nil)
            track()
            bulletinManager.dismissBulletin()
            navigationController?.popViewController(animated: true)
        } else {
            delegate?.callBackWebView(id: dappCommonModel.id, value: "", error: DAppError.sendTransactionFailed)
        }
    }

    func track() {
        SensorsAnalytics.Track.transaction(
            chainType: tokenModel.chain?.chainId ?? "",
            currencyType: tokenModel.symbol,
            currencyNumber: Double(value) ?? 0.0,
            receiveAddress: dappCommonModel.appChain?.to ?? "",
            outcomeAddress: AppModel.current.currentWallet!.address,
            transactionType: .normal
        )
    }
}

extension ContractController: AdvancedViewControllerDelegate {
    func getCustomGas(gasPrice: BigUInt, gas: BigUInt) {
        self.gasPrice = gasPrice
        ethereumGas = Web3Utils.formatToEthereumUnits(gas, toUnits: .eth, decimals: 8, fallbackToScientific: true)
        let bigUIntValue = Web3Utils.parseToBigUInt(value, units: .eth)!
        let totlePay = getTotleValue(value: bigUIntValue, gas: gas)
        totlePayLabel.text = totlePay + tokenModel.symbol
        gasLabel.text = Double(ethereumGas ?? "")!.trailingZerosTrimmed + tokenModel.symbol
    }
}
