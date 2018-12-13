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
    var tokenModel: TokenModel!
    weak var delegate: ContractControllerDelegate?

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var totlePayLabel: UILabel!
    @IBOutlet weak var dappNameLabel: UILabel!
    @IBOutlet weak var requestStringLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "支付详情"

        let wallet = AppModel.current.currentWallet
        if dappCommonModel.chainType == "AppChain" {
            self.tokenModel = wallet!.tokenModelList.first(where: { $0.type == .appChain && $0.chain!.chainId == "\(dappCommonModel.appChain!.chainId)" })
            let gasLimit = dappCommonModel.appChain?.quota?.toBigUInt()
            paramBuilder = TransactionParamBuilder(token: tokenModel, gasPrice: nil, gasLimit: gasLimit)
            paramBuilder.value = dappCommonModel.appChain?.value?.toBigUInt() ?? 0
            paramBuilder.to = dappCommonModel.appChain?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.appChain?.data ?? "")
        } else {
            self.tokenModel = wallet!.tokenModelList.first(where: { $0.type == .ether })
            let gasPrcie = dappCommonModel.eth?.gasPrice?.toBigUInt()
            let gasLimit = dappCommonModel.eth?.gasLimit?.toBigUInt()
            paramBuilder = TransactionParamBuilder(token: tokenModel, gasPrice: gasPrcie, gasLimit: gasLimit)
            paramBuilder.value = dappCommonModel.eth?.value?.toBigUInt() ?? 0
            paramBuilder.to = dappCommonModel.eth?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.eth?.data ?? "")
        }
        paramBuilder.from = wallet!.address

        setUIData()
        observers.append(paramBuilder.observe(\.txFeeText, options: [.initial]) { (_, _) in
            self.updateGasCost()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: TransactionGasCostViewController.self) {
            let controller = segue.destination as! TransactionGasCostViewController
            controller.param = paramBuilder
            controller.dataString = dappCommonModel.eth?.data ?? ""
        }
    }

    func setUIData() {
        let walletModel = AppModel.current.currentWallet!
        fromLabel.text = walletModel.address
        requestStringLabel.text = requestAddress
        dappNameLabel.text = dappName
        toLabel.text = paramBuilder.to
        valueLabel.text = "\(paramBuilder.value.toAmountText(tokenModel.decimals)) \(tokenModel.symbol)"
    }

    func updateGasCost() {
        gasLabel.text =  "\(paramBuilder.txFeeText) \(tokenModel.symbol)"
        totlePayLabel.text = "\((paramBuilder.txFee + paramBuilder.value).toAmountText(tokenModel.decimals)) \(tokenModel.symbol)"
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 && dappCommonModel.chainType == "ETH" {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
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
            currencyNumber: paramBuilder.value.toDouble(tokenModel.decimals),
            receiveAddress: dappCommonModel.appChain?.to ?? "",
            outcomeAddress: AppModel.current.currentWallet!.address,
            transactionType: .normal
        )
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
