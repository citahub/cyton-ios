//
//  MessageSignController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BLTNBoard
import CITA

protocol MessageSignControllerDelegate: class {
    func messageSignCallBackWebView(id: Int, value: String, error: DAppError?)
}

class MessageSignController: UIViewController {
    var dappCommonModel: DAppCommonModel!
    weak var delegate: MessageSignControllerDelegate?

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
        if dappCommonModel.chainType == .cita {
            dataText = dappCommonModel.cita?.data ?? ""
        } else {
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
        switch dappCommonModel.chainType {
        case .cita:
            citaSign(password: password)
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

    func citaSign(password: String) {
        switch dappCommonModel.name {
        case .signMessage:
            citaSignMessage(password: password)
        default:
            break
        }
    }

    func ethSignPersonalMessage(password: String) {
        DispatchQueue.global().async {
            do {
                let messageData = Data.fromHex(self.dappCommonModel.eth?.data ?? "") ?? Data()
                let privateKey = try self.getPrivateKey(password: password)
                guard let signed = try EthereumMessageSigner().signPersonalMessage(message: messageData, privateKey: privateKey) else {
                    throw Error.signMessageFailed
                }
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
                let messageData = Data.fromHex(self.dappCommonModel.eth?.data ?? "") ?? Data()
                let privateKey = try self.getPrivateKey(password: password)
                guard let signed = try EthereumMessageSigner().sign(message: messageData, privateKey: privateKey) else {
                    throw Error.signMessageFailed
                }
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

    func citaSignMessage(password: String) {
        DispatchQueue.global().async {
            do {
                let messageData = Data.fromHex(self.dappCommonModel.eth?.data ?? "") ?? Data()
                let privateKey = try self.getPrivateKey(password: password)
                guard let signed = try MessageSigner().sign(message: messageData, privateKey: privateKey) else {
                    throw Error.signMessageFailed
                }
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
}

extension MessageSignController {
    enum Error: String, LocalizedError {
        case walletNotFound
        case signMessageFailed

        var errorDescription: String? {
            return "MessageSign.Error.\(rawValue)".localized()
        }
    }

    private func getPrivateKey(password: String) throws -> String {
        guard let wallet = AppModel.current.currentWallet!.wallet else {
            throw Error.walletNotFound
        }

        return try WalletManager.default.exportPrivateKey(wallet: wallet, password: password)
    }
}
