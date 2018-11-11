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

enum SendTransactionError: Error {
    case invalidSourceAddress
    case invalidDestinationAddress
    case invalidAmountFormat
    case contractLoadingError
    case retrievingGasPriceError
    case retrievingEstimatedGasError
    case emptyResult
    case noAvailableKeys
    case createTransactionIssue
    case invalidPassword
    case invalidAppChainNode
    case signTXFailed
}

enum TransactionError: Error {
    case requestfailed
}
