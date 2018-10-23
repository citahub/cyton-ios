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
    var requestUrlString = ""
    var dappCommonModel: DAppCommonModel!
    weak var delegate: MessageSignControllerDelegate?
    private var chainType: ChainType = .appChain
    private var tokenModel = TokenModel()
    private var messageSignShowViewController: MessageSignShowViewController!
    private var confirmSendViewController: ConfirmSendViewController!
    private var messageSignPageVC: UIPageViewController!

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
        messageSignShowViewController = storyboard!.instantiateViewController(withIdentifier: "messageSignShowViewController") as? MessageSignShowViewController
        messageSignShowViewController.delegate = self
        confirmSendViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "confirmSendViewController") as? ConfirmSendViewController
        confirmSendViewController.delegate = self
        messageSignPageVC.setViewControllers([messageSignShowViewController], direction: .forward, animated: false)
        setUIData()
    }

    func setUIData() {
        messageSignShowViewController.requestTextField.text = requestUrlString
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
        }
    }

    func appChainSignMessage(password: String) {

    }

    func appChainSignPersonalMessage(password: String) {

    }

    func removeView() {
        view.removeFromSuperview()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dappPageViewController" {
            messageSignPageVC = segue.destination as? UIPageViewController
        }
    }
}

extension MessageSignController: MessageSignShowViewControllerDelegate {
    func clickAgreeButton() {
        messageSignPageVC.setViewControllers([confirmSendViewController], direction: .forward, animated: false)
    }

    func clickRejectButton() {
        removeView()
    }
}

extension  MessageSignController: ConfirmSendViewControllerDelegate {
    func closePayCoverView() {
        removeView()
    }

    func confirmPassword(confirmSendViewController: ConfirmSendViewController, password: String) {
        switch chainType {
        case .appChain:
            appChainSign(password: password)
        case .eth:
            ethSign(password: password)
        }
    }
}
