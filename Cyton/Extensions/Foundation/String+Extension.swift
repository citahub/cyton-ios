//
//  String+Extension.swift
//  Cyton
//
//  Created by Yate Fulham on 2018/08/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

extension String {
    func removeHexPrefix() -> String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }

    func addHexPrefix() -> String {
        if hasPrefix("0x") {
            return self
        }
        return "0x" + self
    }

    func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

    func toBigUInt() -> BigUInt? {
        return BigUInt(string: self)
    }
}
