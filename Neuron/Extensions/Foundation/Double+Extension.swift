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
    // TODO: delete or refactor this
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

    func toAmount(_ decimals: Int = 18) -> BigUInt {
        return Web3Utils.parseToBigUInt(description, decimals: decimals) ?? 0
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
