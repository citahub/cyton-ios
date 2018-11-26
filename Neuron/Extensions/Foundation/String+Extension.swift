//
//  String+Extension.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

extension String {
    func removeHexPrefix() -> String {
        if self.hasPrefix("0x") {
            return String(self.dropFirst(2))
        }
        return self
    }

    func addHexPrefix() -> String {
        if self.hasPrefix("0x") {
            return self
        }
        return "0x" + self
    }

    func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
