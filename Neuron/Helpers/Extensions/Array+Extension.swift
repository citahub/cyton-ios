//
//  Array+Extension.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/24.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

//random array
extension Array {
    public func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }
}
