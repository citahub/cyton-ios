//
//  ServiceErrors.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/5.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

enum EthServiceResult<T> {
    case success(T)
    case error(Error)
}

enum AppChainServiceResult<T> {
    case success(T)
    case error(Error)
}

enum CustomTokenError: Error {
    case wrongBalanceError
    case badNameError
    case badSymbolError
    case undefinedError
}

enum SignMessageResult<T> {
    case success(T)
    case error(Error)
}

enum SendTransactionError: String, LocalizedError {
    case invalidSourceAddress
    case invalidDestinationAddress
    case invalidContractAddress
    case noAvailableKeys
    case createTransactionIssue
    case invalidAppChainNode
    case invalidChainId
    case signTXFailed

    var errorDescription: String? {
        return NSLocalizedString("SendTransactionError.\(rawValue)", comment: "")
    }
}
