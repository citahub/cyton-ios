//
//  WalletManager+Errors.swift
//  Cyton
//
//  Created by James Chen on 2018/11/03.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension WalletManager {
    enum Error: String, LocalizedError {
        case invalidPassword
        case invalidPrivateKey
        case invalidKeystore
        case invalidMnemonic
        case accountAlreadyExists
        case accountNotFound
        case failedToDeleteAccount
        case failedToUpdatePassword
        case failedToSaveKeystore
        case unknown

        var errorDescription: String? {
            return "WalletManager.Error.\(rawValue)".localized()
        }
    }
}
