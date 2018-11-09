//
//  Double+Extension.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/25.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
