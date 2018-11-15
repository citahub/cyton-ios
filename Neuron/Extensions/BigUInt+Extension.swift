//
//  BigUInt+Extension.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/15.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

extension BigUInt {
    public init?(_ text: String) {
        if text.hasPrefix("0x") {
            self.init(text.removeHexPrefix(), radix: 16)
        } else {
            self.init(text, radix: 10)
        }
    }
}
