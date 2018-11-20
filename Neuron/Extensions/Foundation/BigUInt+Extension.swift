//
//  BigUInt+Extension.swift
//  Neuron
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

    func weiToGwei() -> Double {
        return Double.fromAmount(self, decimals: 9)
    }

    init?(string: String) {
        if string.hasPrefix("0x") {
            self.init(string.removeHexPrefix(), radix: 16)
        } else {
            self.init(string)
        }
    }
}
