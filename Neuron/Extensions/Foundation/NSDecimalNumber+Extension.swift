//
//  NSDecimalNumber+Extension.swift
//  Neuron
//
//  Created by 晨风 on 2018/12/5.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    func formatterToString( _ decimals: Int = 18) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? "0"
    }
}
