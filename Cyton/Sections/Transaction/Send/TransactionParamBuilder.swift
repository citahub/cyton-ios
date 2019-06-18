//
//  TransactionParamBuilder.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import web3swift
import RealmSwift

/// Prepare tx params.
class TransactionParamBuilder: NSObject {
    var tokenIdentifier = ""
    var from = ""
    var to = ""
    var value: BigUInt = 0
    var data = Data()
    var contractAddress = ""
    var chainId = ""

    var fetchedGasPrice: BigUInt = BigUInt.parseToBigUInt("1", 9)  // Fetched from node as recommended gas price
    var gasPrice: BigUInt = BigUInt.parseToBigUInt("1", 9) {
        didSet {
            rebuildGasCalculator()
        }
    }

    var gasLimit: BigUInt = GasCalculator.defaultGasLimit {
        didSet {
            rebuildGasCalculator()
        }
    }

    var txFee: BigUInt {
        return gasCalculator.txFee
    }

    @objc dynamic
    private(set) var txFeeText: String = "0"

    var tokenBalance: BigUInt = 0

    @objc dynamic
    private(set) var nativeTokenPrice: Double = 0
    private(set) var nativeTokenDecimals = 18

    private(set) var currencySymbol = ""

    /// Note: this returns true even when native token (ETH) is not enough for tx fee
    ///   when sending ERC20. UI layer should check that.
    var hasSufficientBalance: Bool {
        switch tokenType {
        case .ether, .cita:
            return tokenBalance >= value + txFee
        case .erc20, .citaErc20:
            return tokenBalance >= value
        }
    }

    var tokenType: TokenType
    var rpcNode: String = ""
    var decimals: Int = 18
    var symbol: String
    var nativeCoinSymbol: String

    private var gasCalculator = GasCalculator()

    init(token: Token, gasPrice: BigUInt? = nil, gasLimit: BigUInt? = nil) {
        tokenIdentifier = token.identifier
        tokenType = token.type
        rpcNode = token.chainHost
        decimals = token.decimals
        chainId = token.chainId
        contractAddress = token.address
        symbol = token.symbol
        nativeCoinSymbol = token.nativeTokenSymbol
        tokenBalance = token.balance ?? 0

        super.init()

        if let gasPrice = gasPrice {
            self.gasPrice = gasPrice
        } else {
            fetchGasPrice()
        }
        if let gasLimit = gasLimit {
            self.gasLimit = gasLimit
        } else {
            fetchGasLimit()
        }
        fetchNativeTokenPrice(token: token)
    }

    init(builder: TransactionParamBuilder) {
        tokenIdentifier = builder.tokenIdentifier
        tokenType = builder.tokenType
        rpcNode = builder.rpcNode
        decimals = builder.decimals
        chainId = builder.chainId
        contractAddress = builder.contractAddress
        symbol = builder.symbol
        nativeCoinSymbol = builder.nativeCoinSymbol
        tokenBalance = builder.tokenBalance
        super.init()
        gasPrice = builder.gasPrice
        gasLimit = builder.gasLimit
        from = builder.from
        to = builder.to
        data = builder.data
        nativeTokenPrice = builder.nativeTokenPrice
        currencySymbol = builder.currencySymbol
        rebuildGasCalculator()
    }

    func estimateGasLimit() -> BigUInt {
        switch tokenType {
        case .erc20, .ether:
            var options = TransactionOptions.defaultOptions
            options.gasLimit = .limited(BigUInt(gasLimit))
            options.value = value
            options.from = EthereumAddress(from)!
            let contract = EthereumNetwork().getWeb3().contract(Web3Utils.erc20ABI, at: EthereumAddress(from)!)
            let trans = contract!.method(transactionOptions: options)!
            let estimateGasLimit = (try? trans.estimateGas(transactionOptions: options)) ?? BigUInt(GasCalculator.defaultGasLimit)
            return estimateGasLimit
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
        case .cita, .citaErc20:
            GasPriceFetcher().fetchQuotaPrice(rpcNode: rpcNode, then: fetched)
        }
    }

    // TODO: implement estimate gas
    private func fetchGasLimit() {
        switch tokenType {
        case .ether, .cita:
            gasLimit = GasCalculator.defaultGasLimit
        case .erc20:
            gasLimit = 100_000
        case .citaErc20:
            gasLimit = 200_000
        }
    }

    private func fetchNativeTokenPrice(token: Token) {
        let currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        let tokenSymbol: String = token.nativeTokenSymbol
        currencySymbol = currency.symbol
        DispatchQueue.global().async {
            if let price = TokenPriceLoader().getPrice(symbol: tokenSymbol, currency: currency.short) {
                DispatchQueue.main.async {
                    self.nativeTokenPrice = price
                }
            }
        }
    }

    private func rebuildGasCalculator() {
        gasCalculator = GasCalculator(gasPrice: gasPrice, gasLimit: gasLimit)
        txFeeText = gasCalculator.txFee.toAmountText()
    }
}
