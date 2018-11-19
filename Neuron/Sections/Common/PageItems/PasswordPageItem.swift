//
//  PasswordPageItem.swift
//  Neuron
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

    static func create() -> PasswordPageItem {
        let item = PasswordPageItem(title: "请输入钱包密码")
        item.appearance = PageItemAppearance.default
        item.descriptionText = ""
        item.actionButtonTitle = "确认发送"
        return item
    }

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        if passwordField == nil {
            passwordField = interfaceBuilder.makeTextField(placeholder: "请输入钱包密码", returnKey: .done, delegate: self)
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
            errorMessage = "请输入密码"
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
