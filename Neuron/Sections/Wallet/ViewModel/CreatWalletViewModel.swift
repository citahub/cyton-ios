//
//  CreatWalletViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

@objc protocol CreatWalletViewModelDelegate {
    func reloadView()
    func doPush(mnemonic: String)
}

protocol CreatWalletViewModelInterface {
    var delegate: CreatWalletViewModelDelegate? {get set}

    var nameText: String {get}
    var newPasswordText: String {get}
    var againPasswordText: String {get}
    var isFulfil: Bool {get}

    func textfieldTextChanged(text: String, indexPath: NSIndexPath)
    func setNextButtonTitleColor() -> UIColor
    func setNextButtonBackgroundColor() -> UIColor

    func goNextView()
}

class CreatWalletViewModel: NSObject, CreatWalletViewModelInterface {

    weak var delegate: CreatWalletViewModelDelegate?
    var nameText: String = ""
    var newPasswordText: String = ""
    var againPasswordText: String = ""
    var isFulfil: Bool = false
    var walletModel = WalletModel()

    func textfieldTextChanged(text: String, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            nameText = text
        case 1:
            newPasswordText = text
        case 2:
            againPasswordText = text
        default:
            break
        }
        if didJudgeButtonEnabled() {
            isFulfil = true
        } else {
            isFulfil = false
        }
        delegate?.reloadView()
    }

    func didJudgeButtonEnabled() -> Bool {
        if nameText.count != 0 && newPasswordText.count != 0 && againPasswordText.count != 0 {
            return true
        } else {
            return false
        }
    }

    func setNextButtonTitleColor() -> UIColor {
        if didJudgeButtonEnabled() {
            return ColorFromString(hex: "#ffffff")
        } else {
            return ColorFromString(hex: "#999999")
        }
    }

    func setNextButtonBackgroundColor() -> UIColor {
        if didJudgeButtonEnabled() {
            return ColorFromString(hex: "#2e4af2")
        } else {
            return ColorFromString(hex: "#e6e6e6")
        }
    }

    //在这处理数据的存储
    func goNextView() {
        if case .invalid(let reason) = WalletNameValidator.validate(walletName: nameText) {
            Toast.showToast(text: reason)
            return
        }

        if case .invalid(let reason) = PasswordValidator.validate(password: newPasswordText) {
            Toast.showToast(text: reason)
            return
        }

        if newPasswordText != againPasswordText {
            Toast.showToast(text: "两次密码不一致")
            return
        }

        delegate?.doPush(mnemonic: WalletManager.generateMnemonic())
    }
}
