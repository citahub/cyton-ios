//
//  String+Extension.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension String {
    func removeHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }

    func addHexPrefix() -> String {
        if self.hasPrefix("0x") {
            return self
        }
        return "0x" + self
    }

    var hexValue: Int {
        let str: String = removeHexPrefix().uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48
            if i >= 65 {
                sum -= 7
            }
        }
        return sum
    }
}
