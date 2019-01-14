//
//  PasswordValidator.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

struct PasswordValidator {
    enum Result {
        case valid
        case invalid(String)
    }

    static func validate(password: String) -> Result {
        if password.isEmpty {
            return .invalid("密码不能为空")
        }

        if password.count < 8 {
            return .invalid("密码的长度需要在8位以上")
        }

        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", "^.*?[a-z].*?$")
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", "^.*?[A-Z].*?$")
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", "^.*?[0-9].*?$")
        let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", "^.*?[~!@#$%^&*()-+?:.].*?$")
        let matches = [lowercasePredicate, uppercasePredicate, numberPredicate, specialCharacterPredicate].filter { (predicate) in
            return predicate.evaluate(with: password)
        }

        if matches.count >= 3 {
            return .valid
        } else {
            return .invalid("您的密码安全性太弱，请重新输入")
        }
    }
}
