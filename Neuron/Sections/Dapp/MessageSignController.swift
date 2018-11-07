//
//  MessageSignController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol MessageSignControllerDelegate: class {
    func messageSignCallBackWebView(id: Int, value: String, error: DAppError?)
}

class MessageSignController: UIViewController, TransactionConfirmViewControllerDelegate {
    var dappCommonModel: DAppCommonModel!
    weak var delegate: MessageSignControllerDelegate?
    private var chainType: ChainType = .appChain
    private var tokenModel = TokenModel()
    private var messageSignShowViewController: MessageSignShowViewController!
    private var confirmController: TransactionConfirmViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        messageSignShowViewController = storyboard!.instantiateViewController(withIdentifier: "messageSignShowViewController") as? MessageSignShowViewController
        messageSignShowViewController.delegate = self

        let confirmController: TransactionConfirmViewController = UIStoryboard(name: .transaction).instantiateViewController()
        confirmController.delegate = self
        addChild(confirmController)
        view.addSubview(confirmController.view)
        confirmController.contentViewController = messageSignShowViewController
        self.confirmController = confirmController

        setUIData()
    }

    func transactionConfirmWalletPassword(_ controller: TransactionConfirmViewController, password: String) {
        switch chainType {
        case .appChain:
            appChainSign(password: password)
        case .eth:
            ethSign(password: password)
        }
    }

    func transactionCanceled(_ controller: TransactionConfirmViewController) {
        delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: "", error: DAppError.userCanceled)
        dismiss(animated: false, completion: nil)
    }

    func setUIData() {
        if dappCommonModel.chainType == "AppChain" {
            chainType = .appChain
            messageSignShowViewController.dataText = dappCommonModel.appChain?.data ?? ""
        } else {
            chainType = .eth
            messageSignShowViewController.dataText = dappCommonModel.eth?.data ?? ""
        }
        getTokenModel()
    }

    func getTokenModel() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        switch chainType {
        case .appChain:
            let result = appModel.nativeTokenList.filter { return Int($0.chainId) == self.dappCommonModel.appChain!.chainId}
            guard let model = result.first else {
                return
            }
            self.tokenModel = model
        case .eth:
            let result = appModel.nativeTokenList.filter { return Int($0.chainId) == self.dappCommonModel.eth!.chainId}
            guard let model = result.first else {
                return
            }
            self.tokenModel = model
        }
    }
}

extension MessageSignController: MessageSignShowViewControllerDelegate {
    func clickAgreeButton() {
        confirmController.confirmTransactionInfo()
    }

    func clickRejectButton() {
        confirmController.dismiss()
    }
}

// MARK: - Sign
extension MessageSignController {
    func ethSign(password: String) {
        switch dappCommonModel.name {
        case .signMessage:
            ethSignMessage(password: password)
        case .signPersonalMessage:
            ethSignPersonalMessage(password: password)
        default:
            break
        }
    }

    func appChainSign(password: String) {
        switch dappCommonModel.name {
        case .signMessage:
            appChainSignMessage(password: password)
        case .signPersonalMessage:
            appChainSignPersonalMessage(password: password)
        default:
            break
        }
    }

    func ethSignPersonalMessage(password: String) {
        Toast.showHUD()
        ETHSignMessageService.signPersonal(message: dappCommonModel.eth?.data ?? "", password: password) { (result) in
            Toast.hideHUD()
            switch result {
            case .success(let signed):
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: signed, error: nil)
                self.view.removeFromSuperview()
                self.confirmController.dismiss()
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
        }
    }

    func ethSignMessage(password: String) {
        Toast.showHUD()
        ETHSignMessageService.sign(message: dappCommonModel.eth?.data ?? "", password: password) { (result) in
            Toast.hideHUD()
            switch result {
            case .success(let signed):
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: signed, error: nil)
                self.view.removeFromSuperview()
                self.confirmController.dismiss()
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
        }
    }

    func appChainSignMessage(password: String) {
    }

    func appChainSignPersonalMessage(password: String) {
    }
}
