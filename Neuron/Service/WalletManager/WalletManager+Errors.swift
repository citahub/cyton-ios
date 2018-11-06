//
//  WalletManager+Errors.swift
//  Neuron
//
//  Created by James Chen on 2018/11/03.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension WalletManager {
    enum Error: String, LocalizedError {
        case invalidPassword = "密码错误"
        case invalidPrivateKey = "解析失败"
        case invalidKeystore = "Keystore无效"
        case invalidMnemonic = "助记词无效"
        case accountAlreadyExists = "钱包已经存在"
        case accountNotFound = "该钱包不存在"
        case failedToDeleteAccount = "删除失败"
        case failedToUpdatePassword = "修改密码失败"
        case failedToSaveKeystore = "保存Keystore失败"
        case unknown

        var errorDescription: String? {
            return NSLocalizedString("WalletManager.\(rawValue)", comment: "")
        }
    }
}
