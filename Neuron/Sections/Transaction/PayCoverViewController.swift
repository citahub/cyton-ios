//
//  PayCoverViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/17.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import AppChain
import web3swift
import struct BigInt.BigUInt

protocol DAppPayCoverViewControllerDelegate: class {
    func dappTransactionResult(id: Int, value: String, error: DAppError?)
}

protocol PayCoverViewControllerDelegate: class {
    func popToRootView()
}

class PayCoverViewController: UIViewController {
    var amount: String!
    var tokenModel = TokenModel()
    var walletAddress: String!
    var toAddress: String!
    var gasCost: String!
    var gasPrice: BigUInt! // nervos token , it's quota.
    var extraData: Data!
    var contrackAddress: String = ""
    var tokenType: TokenType = .nervosToken
    var isUseQRCode = false
    var dappCommonModel: DAppCommonModel?

    weak var delegate: PayCoverViewControllerDelegate?
    weak var dappDelegate: DAppPayCoverViewControllerDelegate?

    private var ethTransactionService: EthTransactionService!
    private var nervosTransactionService: NervosTransactionService!
    private var erc20TransactionService: ERC20TransactionService!

    private var confirmPageViewController: UIPageViewController!
    private var confirmAmountViewController: ConfirmAmountViewController!
    private var confirmSendViewController: ConfirmSendViewController!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.frame = CGRect(x: 0, y: ScreenSize.height, width: ScreenSize.width, height: ScreenSize.height)
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
        }, completion: { (_) in
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshDataForConfirmView()
    }

    func refreshDataForConfirmView() {
        confirmAmountViewController = storyboard!.instantiateViewController(withIdentifier: "confirmAmountViewController") as? ConfirmAmountViewController
        confirmAmountViewController.delegate = self
        confirmAmountViewController.amount = amount + "  \(tokenModel.symbol)"
        confirmAmountViewController.fromAddress = walletAddress
        confirmAmountViewController.toAddress = toAddress
        confirmAmountViewController.gas = gasCost
        confirmSendViewController = storyboard!.instantiateViewController(withIdentifier: "confirmSendViewController") as? ConfirmSendViewController
        confirmSendViewController.delegate = self
        confirmPageViewController.setViewControllers([confirmAmountViewController], direction: .forward, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmPageViewController" {
            confirmPageViewController = segue.destination as? UIPageViewController
        }
    }

    // TODO: Refactor
    func prepareEthTransaction(password: String) {
        ethTransactionService = EthTransactionService()
        ethTransactionService.prepareETHTransactionForSending(destinationAddressString: toAddress,
                                                              amountString: amount,
                                                              gasLimit: 21000,
                                                              gasPrice: gasPrice,
                                                              data: extraData!) { (result) in
                                                                switch result {
                                                                case .success(let value):
                                                                    self.dealWithETHDAppCommonModel(password: password, transaction: value)
                                                                case .error(let error):
                                                                    self.failure(error: error)
                                                                }
        }
    }

    func signETHTransaction(password: String, transaction: TransactionIntermediate) {
        ethTransactionService.sign(password: password, transaction: transaction, address: toAddress) { (result) in
            switch result {
            case .success(let transactionIntermediate):
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: transactionIntermediate.transaction.data.toHexString(), error: nil)
            case .error:
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: "", error: DAppError.signTransactionFailed)
            }
        }
    }

    func sendDAppEthTransaction(password: String, transaction: TransactionIntermediate) {
        ethTransactionService.send(password: password, transaction: transaction, completion: { (result) in
            switch result {
            case .success(let value):
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: value.hash.addHexPrefix(), error: nil)
            case .error:
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: "", error: DAppError.sendTransactionFailed)
            }
            Toast.hideHUD()
        })
    }

    func sendEthTransaction(password: String, transaction: TransactionIntermediate) {
        ethTransactionService.send(password: password, transaction: transaction, completion: { (result) in
            switch result {
            case .success:
                self.success()
            case .error(let error):
                self.failure(error: error)
            }
            Toast.hideHUD()
        })
    }

    func dealWithETHDAppCommonModel(password: String, transaction: TransactionIntermediate) {
        guard let dappModel = dappCommonModel else {
            sendEthTransaction(password: password, transaction: transaction)
            return
        }
        switch dappModel.name {
        case .sendTransaction, .signTransaction:
            self.sendDAppEthTransaction(password: password, transaction: transaction)
        default:
            break
        }
    }

    // TODO: Refactor
    func prepareNrevosTransaction(password: String) {
        nervosTransactionService = NervosTransactionService()
        nervosTransactionService.prepareNervosTransactionForSending(address: toAddress,
                                                                    quota: gasPrice,
                                                                    data: extraData,
                                                                    value: amount,
                                                                    tokenHosts: tokenModel.chainHosts,
                                                                    chainId: BigUInt(tokenModel.chainId)!) { (reuslt) in
                                                                        switch reuslt {
                                                                        case .success(let transaction):
                                                                           self.dealWithAppChainDAppCommonModel(password: password, transaction: transaction)
                                                                        case .error(let error):
                                                                            self.failure(error: error)
                                                                        }
        }
    }

    func sendNervosTransaction(password: String, transaction: Transaction) {
        nervosTransactionService.send(password: password, transaction: transaction) { (result) in
            switch result {
            case .success:
                self.success()
            case .error(let error):
                self.failure(error: error)
            }
        }
    }

    func sendDappAppChainTransaction(password: String, transaction: Transaction) {
        nervosTransactionService.send(password: password, transaction: transaction) { (result) in
            switch result {
            case .success(let value):
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: value.hash.toHexString().addHexPrefix(), error: nil)
            case .error:
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: "", error: DAppError.sendTransactionFailed)
            }
            Toast.hideHUD()
            self.view.removeFromSuperview()
        }
    }

    func signNervosTransaction(password: String, transaction: Transaction) {
        nervosTransactionService.sign(password: password, transaction: transaction) { (result) in
            switch result {
            case .success(let value):
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: value, error: nil)
            case .error:
                self.dappDelegate?.dappTransactionResult(id: self.dappCommonModel!.id, value: "", error: DAppError.signTransactionFailed)
            }
            Toast.hideHUD()
            self.view.removeFromSuperview()
        }
    }

    func dealWithAppChainDAppCommonModel(password: String, transaction: Transaction) {
        if dappCommonModel == nil {
            sendNervosTransaction(password: password, transaction: transaction)
        } else {
            switch dappCommonModel!.name {
            case .sendTransaction, .signTransaction:
                self.sendDappAppChainTransaction(password: password, transaction: transaction)
            default:
                break
            }
        }
    }

    func prepareErc20Transaction(password: String) {
        erc20TransactionService = ERC20TransactionService()
        erc20TransactionService.prepareERC20TransactionForSending(destinationAddressString: toAddress,
                                                                  amountString: amount,
                                                                  gasLimit: 21000,
                                                                  gasPrice: gasPrice,
                                                                  erc20TokenAddress: tokenModel.address) { (result) in
                                                                    switch result {
                                                                    case .success(let value):
                                                                        self.sendErc20Transaction(password: password, transaction: value)
                                                                    case .error(let error):
                                                                        self.failure(error: error)
                                                                    }
        }
    }

    func sendErc20Transaction(password: String, transaction: TransactionIntermediate) {
        erc20TransactionService.send(password: password, transaction: transaction, completion: { (result) in
            switch result {
            case .success:
                self.success()
            case .error(let error):
                self.failure(error: error)
            }
        })
    }

    private func success() {
        Toast.hideHUD()
        Toast.showToast(text: "转账成功,请稍后刷新查看")
        view.removeFromSuperview()
        popToRootView()

        guard let amount = Double(amount) else { return }
        SensorsAnalytics.Track.transaction(
            chainType: tokenModel.chainId,
            currencyType: tokenModel.symbol,
            currencyNumber: amount,
            receiveAddress: toAddress,
            outcomeAddress: walletAddress,
            transactionType: .normal
        )
        if isUseQRCode {
            SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: true)
        }
    }

    private func failure(error: Error) {
        Toast.hideHUD()
        Toast.showToast(text: "网络错误，请稍后再试.")
        if isUseQRCode {
            SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: false)
        }
    }

    func popToRootView() {
        delegate?.popToRootView()
    }

}

extension PayCoverViewController: ConfirmSendViewControllerDelegate, ConfirmAmountViewControllerDelegate {
    func confirmPassword(confirmSendViewController: ConfirmSendViewController, password: String) {
        Toast.showHUD()
        switch tokenType {
        case .ethereumToken:
            self.prepareEthTransaction(password: password)
        case .nervosToken:
            self.prepareNrevosTransaction(password: password)
        case .erc20Token:
            self.prepareErc20Transaction(password: password)
        }
    }

    func closePayCoverView() {
        view.removeFromSuperview()
        view = nil
    }

    func readyToPay() {
        confirmPageViewController.setViewControllers([confirmSendViewController], direction: .forward, animated: true)
    }
}
