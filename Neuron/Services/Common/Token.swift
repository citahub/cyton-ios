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
    var name = ""
    var iconUrl: String? = ""
    var address = ""
    var symbol = ""
    var chainName: String? = ""
    var chainId = ""
    var chainHosts = ""
    var isNativeToken = false
    var walletAddress = ""

    private(set) var balance: Double? {
        didSet {
            guard let realm = tokenModel.realm else { return }
            DispatchQueue.main.async {
                try? realm.write {
                    self.tokenModel.tokenBalance = self.balance ?? 0.0
                }
            }
        }
    }
    var price: Double?
    let tokenModel: TokenModel

    init(_ token: TokenModel) {
        tokenModel = token
        name = token.name
        iconUrl = token.iconUrl
        address = token.address
        symbol = token.symbol
        chainId = token.chainId
        chainName = token.chainName
        chainHosts = token.chainHosts
        isNativeToken = token.isNativeToken
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
        case .ether:
            balance = try EthereumNetwork().getWeb3().eth.getBalance(address: EthereumAddress(walletAddress)!)
        case .appChain, .appChainErc20:
            balance = try AppChainNetwork.appChain().rpc.getBalance(address: walletAddress)
        case .erc20:
            let contractAddress = EthereumAddress(address)!
            let walletAddress = EthereumAddress(self.walletAddress)!
            let contract = EthereumNetwork().getWeb3().contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
            let result = try contract.method("balanceOf", parameters: [walletAddress as AnyObject])?.call()
            balance = result?["0"] as! BigUInt
        }
        let balanceText = Web3Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 8) ?? "0"
        self.balance = Double(balanceText)
        refreshBalanceSignal?.leave()
        refreshBalanceSignal = nil
        return self.balance
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
