//
//  ContractController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BLTNBoard
import CITA
import BigInt
import web3swift

protocol ContractControllerDelegate: class {
    func callBackWebView(id: Int, value: String, error: DAppError?)
}

class ContractController: UITableViewController, TransactonSender {
    var requestAddress: String = ""
    var dappName: String = ""
    var dappCommonModel: DAppCommonModel!
    var paramBuilder: TransactionParamBuilder!
    var token: Token!
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
        title = "DApp.Contract.Title".localized()

        let wallet = AppModel.current.currentWallet
        if dappCommonModel.chainType == .cita {
            self.token = wallet!.tokenModelList.first(where: { $0.type == .cita && $0.chain.chainId == "\(dappCommonModel.cita!.chainId)" })?.token
            let gasLimit = dappCommonModel.cita?.quota?.toBigUInt()
            paramBuilder = TransactionParamBuilder(token: token, gasPrice: nil, gasLimit: gasLimit)
            paramBuilder.value = dappCommonModel.cita?.value?.toBigUInt() ?? 0
            paramBuilder.to = dappCommonModel.cita?.to ?? ""
            paramBuilder.data = Data(hex: dappCommonModel.cita?.data ?? "")
        } else {
            self.token = wallet!.tokenModelList.first(where: { $0.type == .ether })?.token
            let gasPrcie = dappCommonModel.eth?.gasPrice?.toBigUInt()
            let gasLimit = dappCommonModel.eth?.gasLimit?.toBigUInt()
            paramBuilder = TransactionParamBuilder(token: token, gasPrice: gasPrcie, gasLimit: gasLimit)
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
        valueLabel.text = "\(paramBuilder.value.toAmountText(token.decimals)) \(token.symbol)"
    }

    func updateGasCost() {
        gasLabel.text =  "\(paramBuilder.txFeeText) \(token.symbol)"
        totlePayLabel.text = "\((paramBuilder.txFee + paramBuilder.value).toAmountText(token.decimals)) \(token.symbol)"
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 && dappCommonModel.chainType == .eth {
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
                guard let wallet = AppModel.current.currentWallet?.wallet else { return }
                guard WalletManager.default.verifyPassword(wallet: wallet, password: password) else {
                    throw "WalletManager.Error.invalidPassword".localized()
                }

                let txHash: TxHash
                if paramBuilder.tokenType == .ether || paramBuilder.tokenType == .erc20 {
                    txHash = try self.sendEthereumTransaction(password: password)
                } else {
                    txHash = try self.sendCITATransaction(password: password)
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
                    if let error = error as? Web3Error {
                        passwordPageItem.errorMessage = error.description.localized()
                    } else if let error = error as? String {
                        passwordPageItem.errorMessage = error
                    } else {
                        passwordPageItem.errorMessage = "交易失败"
                    }
                }
            }
        }
    }

    func transactionDidSend(txhash: TxHash?) {
        if let txhash = txhash {
            delegate?.callBackWebView(id: dappCommonModel.id, value: txhash.addHexPrefix(), error: nil)
            bulletinManager.dismissBulletin()
            navigationController?.popViewController(animated: true)
        } else {
            delegate?.callBackWebView(id: dappCommonModel.id, value: "", error: DAppError.sendTransactionFailed)
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
