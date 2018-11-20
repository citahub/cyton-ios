//
//  SignMessagePageItem.swift
//  Neuron
//
//  Created by James Chen on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

class SignMessagePageItem: BLTNPageItem {
    static func create() -> SignMessagePageItem {
        let item = SignMessagePageItem(title: "DApp签名信息确认")
        item.appearance = PageItemAppearance.default
        item.actionButtonTitle = "确认"
        return item
    }
}
