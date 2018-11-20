//
//  Token.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import Web3swift
import PromiseKit
import BigInt
import EthereumAddress

class Token {
//    var tokenBalance = ""
//    var currencyAmount = ""
    var name = ""
    var iconUrl: String? = ""
    var address = ""
//    var decimals = 18
    var symbol = ""
    var chainName: String? = ""
    var chainId = ""
    var chainHosts = ""
    var isNativeToken = false
    var walletAddress = ""

    var balance: Double?
    var price: Double?

    init(_ token: TokenModel) {
        name = token.name
        iconUrl = token.iconUrl
        address = token.address
        symbol = token.symbol
        chainId = token.chainId
        chainName = token.chainName
        chainHosts = token.chainHosts
        isNativeToken = token.isNativeToken
    }
}

extension Token {
    enum `Type`: String {
        case ether
        case erc20
        case appChain
        case appChainErc20
    }
    var type: Type {
        if isNativeToken {
            if chainId == NativeChainId.ethMainnetChainId {
                return .ether
            } else {
                if address != "" {
                    return .appChainErc20
                } else {
                    return .appChain
                }
            }
        } else {
            return .erc20
        }
    }
}

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.address == rhs.address && lhs.walletAddress == rhs.walletAddress && rhs.type == lhs.type
    }
}
