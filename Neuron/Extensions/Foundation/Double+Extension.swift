//
//  Double+Extension.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/25.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import BigInt

extension Double {
    var trailingZerosTrimmed: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

    /// Format to normal number string such as 3.1415926.
    static var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.roundingMode = .floor
        return formatter
    }()

    var decimal: String {
        return Double.decimalFormatter.string(from: self as NSNumber)!
    }

    func toAmount(_ decimals: Int = 18) -> BigUInt {
        let stringValue = NSDecimalNumber(string: self.description).stringValue
        return Web3Utils.parseToBigUInt(stringValue, decimals: decimals) ?? 0
    }

    func gweiToWei() -> BigUInt {
        return toAmount(9)
    }

    static func fromAmount(_ amount: BigUInt, decimals: Int = 18) -> Double {
        if let value = Web3Utils.formatToPrecision(amount, numberDecimals: decimals, formattingDecimals: 8, fallbackToScientific: true) {
            return Double(value) ?? 0
        } else {
            return 0
        }
    }
}
