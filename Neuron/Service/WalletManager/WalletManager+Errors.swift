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
        case invalidPassword = "密码不正确"
        case invalidPrivateKey = "私钥不正确"
        case invalidKeystore = "Keystore不正确"
        case invalidMnemonic = "助记词不正确"
        case accountAlreadyExists = "该钱包已存在"
        case accountNotFound = "未找到该钱包"
        case failedToDeleteAccount = "删除钱包失败"
        case failedToUpdatePassword = "修改密码失败"
        case failedToSaveKeystore = "保存keystore失败"
        case unknown = "未知错误"

        var errorDescription: String? {
            return NSLocalizedString("\(rawValue)", comment: "")
        }
    }
}
