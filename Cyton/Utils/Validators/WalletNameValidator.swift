//
//  WalletNameValidator.swift
//  Cyton
//
//  Created by XiaoLu on 2018/10/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

struct WalletNameValidator {
    enum Result {
        case valid
        case invalid(String)
    }

    static func validate(walletName: String) -> Result {
        let nameClean = walletName.trimmingCharacters(in: .whitespaces)
        if nameClean.isEmpty {
            return .invalid("钱包名字不能为空")
        }

        if walletName.count > 15 {
            return .invalid("钱包名字不能超过15个字符")
        }

        if WalletManager.default.walletExists(name: walletName) {
            return .invalid("钱包名字已经存在")
        }

        return .valid
    }
}
