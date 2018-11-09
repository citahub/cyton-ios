//
//  GasCalculator.swift
//  Neuron
//
//  Created by James Chen on 2018/11/07.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

/// Get current gas price and estimated gas, calculate gas, etc.
/// Ether = Tx Fees = Gas Limit * Gas Price
struct GasCalculator {
    // Default to 20 Gwei (which is not very reasonable when Ethereum is under congestion)
    static let defaultGasPrice = Web3Utils.parseToBigUInt("20", units: .eth)!

    var gasPrice: BigUInt
    var gasLimit: UInt64

    init(gasPrice: BigUInt = GasCalculator.defaultGasPrice, gasLimit: UInt64 = 21_000) {
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
    }

    var txFee: Double {
        return GasCalculator.txFee(gasPrice: gasPrice, gasLimit: gasLimit)
    }
}

extension GasCalculator {
    /// Get current gas price (Gwei)
    static func gasPrice() -> BigUInt {
        do {
            return try EthereumNetwork().getWeb3().eth.getGasPrice()
        } catch {
            return defaultGasPrice
        }
    }

    /// Get current gas price asynchronously
    static func getGasPrice(then: @escaping (BigUInt) -> Void) {
        DispatchQueue.global().async {
            let price = gasPrice()
            DispatchQueue.main.async {
                then(price)
            }
        }
    }

    /// Calculate tx fee (ETH) giving gas price and gas limit.
    /// - Parameters:
    ///   - gasPrice: Gas price as GWei.
    ///   - gasLimit: Gas limit.
    /// - Returns: Calculated tx fee as Ether.
    static func txFee(gasPrice: BigUInt, gasLimit: UInt64 = 21_000) -> Double {
        let fee = gasPrice * BigUInt(gasLimit)
        return Double(Web3Utils.formatToEthereumUnits(fee, toUnits: .eth, decimals: 10)!)!
    }

    // TODO: provide estimate gas functionality
}
