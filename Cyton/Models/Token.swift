//
//  Token.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import RealmSwift

enum TokenType: String {
    case ether
    case erc20
    case cita
    case citaErc20
}

class Token {
    let name: String
    let iconUrl: String
    let address: String
    let symbol: String
    let chainName: String
    let chainId: String
    let chainHost: String
    let isNativeToken: Bool
    let type: TokenType
    let decimals: Int

    let identifier: String
    let walletAddress: String

    var price: Double?

    init(_ token: TokenModel, _ walletAddress: String? = nil) {
        name = token.name
        iconUrl = token.iconUrl ?? ""
        address = token.address
        symbol = token.symbol
        chainId = token.chain.chainId
        chainName = token.chain.chainName
        chainHost = token.chain.httpProvider
        isNativeToken = token.isNativeToken
        type = token.type
        decimals = token.decimals
        identifier = token.identifier

        self.walletAddress = walletAddress != nil ? walletAddress! : AppModel.current.currentWallet!.address
        let balanceList = walletModel.balanceList
        if let balanceText = balanceList.first(where: { $0.identifier == identifier })?.value {
            balance = BigUInt(balanceText)
        }
    }

    // MARK: - balance

    var balance: BigUInt? {
        didSet {
            let balanceText = balance != nil ? String(balance!) : nil
            let realm = try! Realm()
            if let tokenBalance = walletModel.balanceList.first(where: { $0.identifier == identifier }) {
                try? realm.write {
                    tokenBalance.value = balanceText
                }
            } else {
                let tokenBalance = TokenBalance()
                tokenBalance.identifier = identifier
                tokenBalance.value = balanceText
                try? realm.write {
                    walletModel.balanceList.append(tokenBalance)
                }
            }
        }
    }

    private var refreshBalanceSignal: DispatchGroup?

    @discardableResult func refreshBalance() throws -> BigUInt? {
        if let signal = refreshBalanceSignal {
            signal.wait()
            return self.balance
        }
        refreshBalanceSignal = DispatchGroup()
        refreshBalanceSignal?.enter()
        defer {
            refreshBalanceSignal?.leave()
            refreshBalanceSignal = nil
        }

        switch type {
        case .cita :
            balance = try CITANetwork(url: chainHost).getBalance(walletAddress: walletAddress)
        case .citaErc20 :
            balance = try CITANetwork(url: chainHost).getErc20Balance(walletAddress: walletAddress, contractAddress: address)
        case .ether:
            balance = try EthereumBalanceLoader(web3: EthereumNetwork().getWeb3(), address: walletAddress).getBalance()
        case .erc20:
            balance = try EthereumBalanceLoader(web3: EthereumNetwork().getWeb3(), address: walletAddress).getTokenBalance(address: address)
        }
        refreshBalanceSignal?.leave()
        refreshBalanceSignal = nil
        return self.balance
    }
}

extension Token {
    var tokenModel: TokenModel {
        let realm = try! Realm()
        return realm.object(ofType: TokenModel.self, forPrimaryKey: identifier)!
    }
    var walletModel: WalletModel {
        return (try! Realm()).object(ofType: WalletModel.self, forPrimaryKey: walletAddress)!
    }
}

extension Token {
    var nativeTokenSymbol: String {
        switch type {
        case .erc20, .citaErc20:
            return tokenModel.chain.nativeToken.symbol
        case .ether, .cita:
            return symbol
        }
    }
    var nativeToken: Token {
        return tokenModel.chain.nativeToken.token
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

extension TokenModel {
    var token: Token { return Token(self) }
}
