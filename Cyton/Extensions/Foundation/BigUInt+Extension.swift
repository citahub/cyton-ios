//
//  BigUInt+Extension.swift
//  Cyton
//
//  Created by James Chen on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

// MARK: - Ethereum Unit Conversion
extension BigUInt {
    enum EthereumUnit {
        case wei, gwei, ether  // Ignore other units as they're rarely used.
    }

    func toWei(from unit: EthereumUnit) -> BigUInt {
        switch unit {
        case .wei:
            return self
        case .gwei:
            return self * BigUInt(10).power(9)
        case .ether:
            return self * BigUInt(10).power(18)
        }
    }

    func toGwei(from unit: EthereumUnit) -> BigUInt {
        switch unit {
        case .wei:
            return self / BigUInt(10).power(9)
        case .gwei:
            return self
        case .ether:
            return self * BigUInt(10).power(9)
        }
    }

    func toEther(from unit: EthereumUnit) -> BigUInt {
        switch unit {
        case .wei:
            return self / BigUInt(10).power(18)
        case .gwei:
            return self / BigUInt(10).power(9)
        case .ether:
            return self
        }
    }

    // From natural
    func toQuota() -> BigUInt {
        return self * BigUInt(10).power(18)
    }

    // From quota to natural
    func fromQuota() -> BigUInt {
        return self / BigUInt(10).power(18)
    }

    func toGweiText() -> String {
        return toAmountText(9)
    }

    init?(string: String) {
        if string.hasPrefix("0x") {
            self.init(string.removeHexPrefix(), radix: 16)
        } else {
            self.init(string)
        }
    }

    func toAmountText(_ decimals: Int = 18) -> String {
        if self == 0 { return "0" }
        if self > Int(0.00000001 * pow(10, Double(decimals))) {
            let formattingDecimals = decimals < 8 ? decimals : 8
            return toDecimalNumber(decimals).formatterToString(formattingDecimals)
        } else {
            let numberText = toDecimalNumber(decimals).formatterToString(18)
            let double = Double(numberText)!
            return double.description
        }
    }

    func toDecimalNumber(_ decimals: Int = 18) -> NSDecimalNumber {
        let text = Web3Utils.formatToPrecision(self, numberDecimals: decimals, formattingDecimals: decimals)
        return NSDecimalNumber(string: text)
    }

    func toDouble(_ decimals: Int = 18) -> Double {
        return Double(toDecimalNumber(decimals).formatterToString(decimals)) ?? 0
    }

    static func parseToBigUInt(_ amount: String, _ decimals: Int = 18) -> BigUInt {
        let formatText = NSDecimalNumber(string: amount).formatterToString(decimals)
        return Web3Utils.parseToBigUInt(formatText, decimals: decimals) ?? 0
    }
}
