//
//  UIntExtension.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

extension UInt {
    static func fromHex(_ string: String) -> UInt {
        guard let bigUint = BigUInt(string.removeHexPrefix(), radix: 16) else { return 0 }
        return bigUint.words[0]
    }
}
