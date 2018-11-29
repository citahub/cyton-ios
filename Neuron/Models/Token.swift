//
//  Token.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import EthereumAddress
import RealmSwift

enum TokenType: String {
    case ether
    case erc20
    case appChain
    case appChainErc20
}

class Token {
    var name: String
    var iconUrl: String? = ""
    var address: String
    var symbol: String
    var chainName: String? = ""
    var chainId: String
    var chainHosts: String
    var isNativeToken: Bool
    var walletAddress = ""
    var type: TokenType
    var decimals = 18
    let identifier: String

    var tokenModel: TokenModel {
        let realm = try! Realm()
        return realm.object(ofType: TokenModel.self, forPrimaryKey: identifier)!
    }

    private(set) var balance: Double? {
        didSet {
            try? tokenModel.realm!.write {
                tokenModel.tokenBalance = balance ?? 0.0
            }
        }
    }
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
        type = token.type
        decimals = token.decimals
        identifier = token.identifier
    }

    // MARK: - balance
    private var refreshBalanceSignal: DispatchGroup?

    @discardableResult func refreshBalance() throws -> Double? {
        if let signal = refreshBalanceSignal {
            signal.wait()
            return self.balance
        }
        refreshBalanceSignal = DispatchGroup()
        refreshBalanceSignal?.enter()
        let balance: BigUInt
        switch type {
        case .appChain, .appChainErc20:
            balance = try AppChainNetwork.appChain(url: URL(string: chainHosts)).rpc.getBalance(address: walletAddress)
        case .ether:
            balance = try EthereumBalanceLoader(web3: EthereumNetwork().getWeb3(), address: walletAddress).getBalance()
        case .erc20:
            balance = try EthereumBalanceLoader(web3: EthereumNetwork().getWeb3(), address: walletAddress).getTokenBalance(address: address)
        }
        self.balance = Double.fromAmount(balance, decimals: decimals)
        refreshBalanceSignal?.leave()
        refreshBalanceSignal = nil
        return self.balance
    }
}

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        return
            lhs.type == rhs.type &&
            lhs.address == rhs.address &&
            lhs.symbol == rhs.symbol &&
            lhs.walletAddress == rhs.walletAddress
    }
}
