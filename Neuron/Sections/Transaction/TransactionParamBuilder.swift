//
//  TransactionParamBuilder.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

/// Prepare tx params.
class TransactionParamBuilder: NSObject {
    var from: String = ""
    var to = ""
    var value: BigUInt = 0
    var data = Data()
    var contractAddress = ""
    var chainId = ""

    var fetchedGasPrice: BigUInt = 1  // Fetched from node as recommended gas price
    var gasPrice: BigUInt = 1 {
        didSet {
            rebuildGasCalculator()
        }
    }

    var gasLimit: UInt64 = GasCalculator.defaultGasLimit {
        didSet {
            rebuildGasCalculator()
        }
    }

    var txFee: BigUInt {
        return gasCalculator.txFee
    }

    @objc dynamic
    private(set) var txFeeNatural: Double = 0

    var tokenBalance: BigUInt = 0

    /// Note: this returns true even when native token (ETH) is not enough for tx fee
    ///   when sending ERC20. UI layer should check that.
    var hasSufficientBalance: Bool {
        switch tokenType {
        case .ether, .appChain:
            return tokenBalance >= txFee + value
        case .erc20, .appChainErc20:
            return tokenBalance >= value
        }
    }

    var tokenType: TokenType
    var rpcNode: String = ""
    var decimals: Int = 18
    var symbol: String
    var nativeCoinSymbol: String

    private var gasCalculator = GasCalculator()

    init(token: TokenModel) {
        tokenType = token.type
        rpcNode = token.chainHosts
        decimals = token.decimals
        chainId = token.chainId
        contractAddress = token.address
        symbol = token.symbol
        nativeCoinSymbol = token.gasSymbol
        tokenBalance = token.tokenBalance.toAmount(token.decimals)

        super.init()

        fetchGasPrice()
        fetchGasLimit()
    }

    private func fetchGasPrice() {
        func fetched(price: BigUInt) {
            self.fetchedGasPrice = price
            self.gasPrice = price
        }

        switch tokenType {
        case .ether, .erc20:
            GasPriceFetcher().fetchGasPrice(then: fetched)
        case .appChain, .appChainErc20:
            GasPriceFetcher().fetchQuotaPrice(rpcNode: rpcNode, then: fetched)
        }
    }

    // TODO: implement estimate gas
    private func fetchGasLimit() {
        switch tokenType {
        case .ether, .appChain:
            gasLimit = GasCalculator.defaultGasLimit
        case .erc20, .appChainErc20:
            gasLimit = 100_000
        }
    }

    private func rebuildGasCalculator() {
        gasCalculator = GasCalculator(gasPrice: gasPrice, gasLimit: gasLimit)
        txFeeNatural = gasCalculator.txFeeNatural
    }
}
