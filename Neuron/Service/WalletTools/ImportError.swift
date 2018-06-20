//
//  ImportError.swift
//  VIPWallet
//
//  Created by Ryan on 2018/4/9.
//  Copyright © 2018年 Qingkong. All rights reserved.
//

import Foundation

enum ImportError : Error {
    case invalidatePrivateKey
    case invalidateJSONKey
    case openKeyStoreFailed
    case accountAlreadyExists
    case accountNotExisits
    case wrongPassword
    case invalidateMnemonic
    case unknown
    case invalidateAddress
    case invalidateTransactionInfo
    case networkError
    case wrongParams;
}
