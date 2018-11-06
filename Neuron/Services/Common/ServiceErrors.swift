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

enum SendEthError: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case contractLoadingError
    case retrievingGasPriceError
    case retrievingEstimatedGasError
    case emptyResult
    case noAvailableKeys
    case createTransactionIssue
    case invalidPassword
}

enum TransactionError: Error {
    case requestfailed
}

// Nervos Error
enum NervosServiceResult<T> {
    case success(T)
    case error(Error)
}

enum SendNervosError: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case contractLoadingError
    case retrievingGasPriceError
    case retrievingEstimatedGasError
    case emptyResult
    case noAvailableKeys
    case createTransactionIssue
    case emptyNonce
}

enum NervosSignError: Error {
    case signTXFailed
}
