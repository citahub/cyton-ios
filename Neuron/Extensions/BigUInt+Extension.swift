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
    init?(string: String) {
        if string.hasPrefix("0x") {
            self.init(string.removeHexPrefix(), radix: 16)
        } else {
            self.init(string)
        }
    }
}
