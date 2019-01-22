//
//  PasswordPageItem.swift
//  Cyton
//
//  Created by James Chen on 2018/11/19.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

class PasswordPageItem: BLTNPageItem {
    var passwordField: UITextField!

    var errorMessage: String? {
        didSet {
            if let message = errorMessage {
                descriptionLabel?.textColor = .red
                descriptionLabel?.text = message
            } else {
                // How to revert to default style?
            }
        }
    }

    static func create(title: String = "Wallet.Details.ChangePassword.inputPassword".localized(), actionButtonTitle: String = "Common.confirm".localized()) -> PasswordPageItem {
        let item = PasswordPageItem(title: title)
        item.appearance = PageItemAppearance.default
        item.descriptionText = ""
        item.actionButtonTitle = actionButtonTitle
        return item
    }

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        if passwordField == nil {
            passwordField = interfaceBuilder.makeTextField(placeholder: "Wallet.Details.ChangePassword.inputPassword".localized(), returnKey: .done, delegate: self)
            passwordField.isSecureTextEntry = true
        }
        return [passwordField]
    }

    override func tearDown() {
        super.tearDown()
        passwordField?.delegate = nil
    }

    override func actionButtonTapped(sender: UIButton) {
        passwordField.resignFirstResponder()

        if validateInput() {
            super.actionButtonTapped(sender: sender)
        }
    }

    private func isInputValid(text: String?) -> Bool {
        if text == nil || text!.isEmpty {
            return false
        }

        return true
    }

    @discardableResult
    private func validateInput() -> Bool {
        if isInputValid(text: passwordField.text) {
            return true
        } else {
            errorMessage = "Wallet.Details.ChangePassword.inputPassword".localized()
            return false
        }
    }
}

extension PasswordPageItem: UITextFieldDelegate {
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
