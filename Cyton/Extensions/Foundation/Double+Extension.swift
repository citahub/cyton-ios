//
//  Double+Extension.swift
//  Cyton
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
}
