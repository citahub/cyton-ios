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

class MessageSignController: UIViewController {
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
        addChild(confirmController)
        view.addSubview(confirmController.view)
        confirmController.contentViewController = messageSignShowViewController
        self.confirmController = confirmController

        setUIData()
        registerEventStrategy(with: TransactionConfirmSendViewController.Event.confirm.rawValue, action: #selector(confirmWalletPassword(userInfo:)))
        registerEventStrategy(with: TransactionConfirmViewController.Event.userCanceled.rawValue, action: #selector(closeConfirmWalletPasswordView))
    }

    @objc func confirmWalletPassword(userInfo: [String: String]) {
        let password = userInfo["password"] ?? ""
        switch chainType {
        case .appChain:
            appChainSign(password: password)
        case .eth:
            ethSign(password: password)
        }
    }

    @objc func closeConfirmWalletPasswordView() {
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
        confirmController.confirmInfo()
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
            switch result {
            case .success(let signed):
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: signed, error: nil)
            case .error:
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: "", error: DAppError.signTransactionFailed)
            }
            Toast.hideHUD()
            self.view.removeFromSuperview()
        }
    }

    func ethSignMessage(password: String) {
        Toast.showHUD()
        ETHSignMessageService.sign(message: dappCommonModel.eth?.data ?? "", password: password) { (result) in
            switch result {
            case .success(let signed):
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: signed, error: nil)
            case .error:
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: "", error: DAppError.signTransactionFailed)
            }
            Toast.hideHUD()
            self.view.removeFromSuperview()
        }
    }

    func appChainSignMessage(password: String) {
    }

    func appChainSignPersonalMessage(password: String) {
    }
}
