//
//  PasswordValidator.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

struct PasswordValidator {
    static func isValid(password: String) -> Bool {
        if password.isEmpty {
            // FIXME: UI action should NOT happen inside validator!
            NeuLoad.showToast(text: "密码不能为空")
            return false
        }
        if password.count < 8 || password.count > 50 {
            NeuLoad.showToast(text: "密码的长度为8到50")
            return false
        }

        let lowerPredicate = "^.*?[a-z].*?$"
        let uppercasePredicate = "^.*?[A-Z].*?$"
        let numberPredicate = "^.*?[0-9].*?$"
        let specialPredicate = "^.*?[~!@#$%^&*()-+?:.].*?$"

        let lowerBool = NSPredicate(format: "SELF MATCHES %@", lowerPredicate)
        let uppercaseBool = NSPredicate(format: "SELF MATCHES %@", uppercasePredicate)
        let numberBool = NSPredicate(format: "SELF MATCHES %@", numberPredicate)
        let specialBool = NSPredicate(format: "SELF MATCHES %@", specialPredicate)

        var totleConform = 0
        if lowerBool.evaluate(with: password) == true {
            totleConform = totleConform + 1
        }
        if uppercaseBool.evaluate(with: password) {
            totleConform = totleConform + 1
        }
        if numberBool.evaluate(with: password) {
            totleConform = totleConform + 1
        }
        if specialBool.evaluate(with: password) {
            totleConform = totleConform + 1
        }

        if totleConform >= 3 {
            return true
        } else {
            NeuLoad.showToast(text: "密码太弱请重新输入")
            return false
        }
    }
}
