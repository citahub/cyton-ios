//
//  SendTransactionError.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/5.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

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
        return "SendTransactionError.\(rawValue)".localized()
    }
}
