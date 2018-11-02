//
//  ImportError.swift
//  Neuron
//
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation

enum ImportError: Error {
    case invalidatePrivateKey
    case invalidateJSONKey
    case openKeystoreFailed
    case accountAlreadyExists
    case accountNotExisits
    case wrongPassword
    case invalidateMnemonic
    case unknown
    case invalidateAddress
    case invalidateTransactionInfo
    case networkError
    case wrongParams
}
