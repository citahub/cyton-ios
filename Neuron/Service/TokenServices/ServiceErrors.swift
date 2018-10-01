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

enum SendEthResult<T> {
    case success(T)
    case error(Error)
}

enum SendEthErrors: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case contractLoadingError
    case retrievingGasPriceError
    case retrievingEstimatedGasError
    case emptyResult
    case noAvailableKeys
    case createTransactionIssue
}

enum TransactionErrors: Error {
    case requestfailed
}

// Nervos Error
enum NervosServiceResult<T> {
    case success(T)
    case error(Error)
}

enum SendNervosErrors: Error {
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

enum SendNervosResult<T> {
    case success(T)
    case error(Error)
}

enum NervosSignErrors: Error {
    case signTXFailed
}
