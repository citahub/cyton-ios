//
//  MessageSignController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

protocol MessageSignControllerDelegate: class {
    func messageSignCallBackWebView(id: Int, value: String, error: DAppError?)
}

class MessageSignController: UIViewController {
    var dappCommonModel: DAppCommonModel!
    weak var delegate: MessageSignControllerDelegate?
    private var chainType: ChainType = .appChain

    private lazy var messagePageItem: SignMessagePageItem = {
        return SignMessagePageItem.create()
    }()
    private lazy var bulletinManager: BLTNItemManager = {
        let passwordPageItem = createPasswordPageItem()
        messagePageItem.next = passwordPageItem
        messagePageItem.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        messagePageItem.dismissalHandler = { [weak self] item in
            self?.cancel()
        }

        return BLTNItemManager(rootItem: messagePageItem)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataText: String
        if dappCommonModel.chainType == "AppChain" {
            chainType = .appChain
            dataText = dappCommonModel.appChain?.data ?? ""
        } else {
            chainType = .eth
            dataText = dappCommonModel.eth?.data ?? ""
        }
        messagePageItem.descriptionText = String(decoding: Data.fromHex(dataText)!, as: UTF8.self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        bulletinManager.showBulletin(above: self)
    }

    private func createPasswordPageItem() -> PasswordPageItem {
        let passwordPageItem = PasswordPageItem.create()

        passwordPageItem.actionHandler = { [weak self] item in
            item.manager?.displayActivityIndicator()
            guard let self = self else {
                return
            }
            self.signMessage(password: passwordPageItem.passwordField.text!)
        }

        passwordPageItem.dismissalHandler = { [weak self] item in
            self?.cancel()
        }

        return passwordPageItem
    }

    private func finish(signed: String) {
        delegate?.messageSignCallBackWebView(id: dappCommonModel!.id, value: signed, error: nil)
        bulletinManager.dismissBulletin()
        dismiss(animated: false)
    }

    private func cancel() {
        delegate?.messageSignCallBackWebView(id: dappCommonModel!.id, value: "", error: DAppError.userCanceled)
        dismiss(animated: false)
    }

    private func showSignError(_ error: String) {
        bulletinManager.hideActivityIndicator()
        let passwordPageItem = createPasswordPageItem()
        bulletinManager.push(item: passwordPageItem)
        passwordPageItem.errorMessage = error
    }
}

// MARK: - Sign

private extension MessageSignController {
    func signMessage(password: String) {
        switch chainType {
        case .appChain:
            appChainSign(password: password)
        case .eth:
            ethSign(password: password)
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
        DispatchQueue.global().async {
            do {
                let signed = try ETHSignMessageService.signPersonal(message: self.dappCommonModel.eth?.data ?? "", password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.finish(signed: signed)
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.showSignError(error.localizedDescription)
                }
            }
        }
    }

    func ethSignMessage(password: String) {
        DispatchQueue.global().async {
            do {
                let signed = try ETHSignMessageService.sign(message: self.dappCommonModel.eth?.data ?? "", password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.finish(signed: signed)
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.showSignError(error.localizedDescription)
                }
            }
        }
    }

    func appChainSignMessage(password: String) {
        // TODO: connect this
    }

    func appChainSignPersonalMessage(password: String) {
        // TODO: connect this
    }
}
