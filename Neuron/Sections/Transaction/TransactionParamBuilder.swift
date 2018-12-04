//
//  TransactionParamBuilder.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import Web3swift
import EthereumAddress

/// Prepare tx params.
class TransactionParamBuilder: NSObject {
    var from: String = ""
    var to = ""
    var value: BigUInt = 0
    var data = Data()
    var contractAddress = ""
    var chainId = ""
    var amount = 0.0

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
    var balance: Double = 0

    @objc dynamic
    private(set) var tokenPrice: Double = 0

    private(set) var currencySymbol = ""

    /// Note: this returns true even when native token (ETH) is not enough for tx fee
    ///   when sending ERC20. UI layer should check that.
    var hasSufficientBalance: Bool {
        switch tokenType {
        case .ether, .appChain:
            let amount = NSDecimalNumber(string: self.amount.description).adding(NSDecimalNumber(string: txFeeNatural.description))
            let balance = NSDecimalNumber(string: self.balance.description)
            return balance.doubleValue >= amount.doubleValue
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
        balance = token.tokenBalance

        super.init()

        fetchGasPrice()
        fetchGasLimit()
        fetchTokenPrice(token: token)
    }

    init(builder: TransactionParamBuilder) {
        tokenType = builder.tokenType
        rpcNode = builder.rpcNode
        decimals = builder.decimals
        chainId = builder.chainId
        contractAddress = builder.contractAddress
        symbol = builder.symbol
        nativeCoinSymbol = builder.nativeCoinSymbol
        tokenBalance = builder.tokenBalance
        balance = builder.balance
        super.init()
        gasPrice = builder.gasPrice
        gasLimit = builder.gasLimit
        from = builder.from
        to = builder.to
        tokenPrice = builder.tokenPrice
        currencySymbol = builder.currencySymbol
        rebuildGasCalculator()
    }

    func estimateGasLimit() -> UInt64 {
        switch tokenType {
        case .erc20, .ether:
            var options = TransactionOptions.defaultOptions
            options.gasLimit = .limited(BigUInt(gasLimit))
            options.value = value
            options.from = EthereumAddress(from)!
            let contract = EthereumNetwork().getWeb3().contract(Web3Utils.erc20ABI, at: EthereumAddress(from)!)
            let trans = contract!.method(transactionOptions: options)!
            let estimateGasLimit = (try? trans.estimateGas(transactionOptions: options)) ?? BigUInt(GasCalculator.defaultGasLimit)
            return UInt64(estimateGasLimit)
        default:
            return GasCalculator.defaultGasLimit
        }
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

    private func fetchTokenPrice(token: TokenModel) {
        let currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        let symbol = token.symbol
        currencySymbol = currency.symbol
        DispatchQueue.global().async {
            if let price = TokenPriceLoader().getPrice(symbol: symbol, currency: currency.short) {
                DispatchQueue.main.async {
                    self.tokenPrice = price
                }
            }
        }
    }

    private func rebuildGasCalculator() {
        gasCalculator = GasCalculator(gasPrice: gasPrice, gasLimit: gasLimit)
        txFeeNatural = gasCalculator.txFeeNatural
    }
}
