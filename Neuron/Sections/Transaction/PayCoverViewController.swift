//
//  PayCoverViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/17.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import Nervos
import web3swift

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
    weak var delegate: PayCoverViewControllerDelegate?

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

    func prepareEthTransaction(password: String) {
        ethTransactionService = EthTransactionService()
        ethTransactionService.prepareETHTransactionForSending(destinationAddressString: toAddress,
                                                              amountString: amount,
                                                              gasLimit: 21000,
                                                              walletPassword: password,
                                                              gasPrice: gasPrice,
                                                              data: extraData!) { (result) in
                                                                switch result {
                                                                case .success(let value):
                                                                    self.sendEthTransaction(password: password, transaction: value)
                                                                case .error(let error):
                                                                    Toast.showToast(text: error.localizedDescription)
                                                                    Toast.hideHUD()
                                                                }
        }
    }

    func sendEthTransaction(password: String, transaction: TransactionIntermediate) {
        ethTransactionService.send(password: password, transaction: transaction, completion: { (result) in
            switch result {
            case .success:
                Toast.showToast(text: "转账成功,请稍后刷新查看")
                self.view.removeFromSuperview()
                self.popToRootView()
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
            Toast.hideHUD()
        })
    }

    func prepareNrevosTransaction(password: String) {
        nervosTransactionService = NervosTransactionService()
        nervosTransactionService.prepareNervosTransactionForSending(address: toAddress,
                                                                    quota: gasPrice,
                                                                    data: extraData,
                                                                    value: amount,
                                                                    chainId: BigUInt(tokenModel.chainId)!) { (reuslt) in
                                                                        switch reuslt {
                                                                        case .success(let transaction):
                                                                            self.sendNervosTransaction(password: password, transaction: transaction)
                                                                        case .error(let error):
                                                                            Toast.showToast(text: error.localizedDescription)
                                                                            Toast.hideHUD()
                                                                        }
        }
    }

    func sendNervosTransaction(password: String, transaction: NervosTransaction) {
        nervosTransactionService.send(password: password, transaction: transaction) { (result) in
            switch result {
            case .success:
                Toast.showToast(text: "转账成功,请稍后查看")
                self.view.removeFromSuperview()
                self.popToRootView()
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
            Toast.hideHUD()
        }
    }

    func prepareErc20Transaction(password: String) {
        erc20TransactionService = ERC20TransactionService()
        erc20TransactionService.prepareERC20TransactionForSending(destinationAddressString: toAddress,
                                                                  amountString: amount,
                                                                  gasLimit: 21000,
                                                                  walletPassword: password,
                                                                  gasPrice: gasPrice,
                                                                  erc20TokenAddress: tokenModel.address) { (result) in
                                                                    switch result {
                                                                    case .success(let value):
                                                                        self.sendErc20Transaction(password: password, transaction: value)
                                                                    case .error(let error):
                                                                        Toast.showToast(text: error.localizedDescription)
                                                                        Toast.hideHUD()
                                                                    }
        }
    }

    func sendErc20Transaction(password: String, transaction: TransactionIntermediate) {
        erc20TransactionService.send(password: password, transaction: transaction, completion: { (result) in
            switch result {
            case .success:
                Toast.showToast(text: "转账成功,请稍后刷新查看")
                self.view.removeFromSuperview()
                self.popToRootView()
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
            Toast.hideHUD()
        })
    }

    func popToRootView() {
        delegate?.popToRootView()
    }

}

extension PayCoverViewController: ConfirmSendViewControllerDelegate, ConfirmAmountViewControllerDelegate {
    func sendTransaction(confirmSendViewController: ConfirmSendViewController, password: String) {
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
