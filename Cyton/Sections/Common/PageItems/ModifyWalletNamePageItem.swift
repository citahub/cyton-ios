//
//  ModifyWalletNamePageItem.swift
//  Cyton
//
//  Created by XiaoLu on 2018/11/21.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

class ModifyWalletNamePageItem: BLTNPageItem {
    var walletNameField: UITextField!

    var errorMessage: String? {
        didSet {
            if let message = errorMessage {
                descriptionLabel?.textColor = .red
                descriptionLabel?.text = message
            }
        }
    }

    static func create(title: String = "Wallet.Details.ChangeName.inputName".localized(), actionButtonTitle: String = "Common.confirm".localized()) -> ModifyWalletNamePageItem {
        let item = ModifyWalletNamePageItem(title: title)
        item.appearance = PageItemAppearance.default
        item.descriptionText = ""
        item.actionButtonTitle = actionButtonTitle
        return item
    }

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        if walletNameField == nil {
            walletNameField = interfaceBuilder.makeTextField(placeholder: "Wallet.Details.ChangeName.inputName".localized(), returnKey: .done, delegate: self)
            walletNameField.isSecureTextEntry = false
        }
        return [walletNameField]
    }

    override func tearDown() {
        super.tearDown()
        walletNameField?.delegate = nil
    }

    override func actionButtonTapped(sender: UIButton) {
        walletNameField.resignFirstResponder()

        if validateInput() {
            super.actionButtonTapped(sender: sender)
        } else {
            walletNameField.text = ""
        }
    }

    @discardableResult
    private func validateInput() -> Bool {
        if let walletName = walletNameField.text {
            if case .invalid(let reason) = WalletNameValidator.validate(walletName: walletName) {
                errorMessage = reason
                return false
            } else {
                return true
            }
        } else {
            errorMessage = "Wallet.Details.ChangeName.inputName".localized()
            return false
        }
    }
}

extension ModifyWalletNamePageItem: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validateInput()
    }
}
