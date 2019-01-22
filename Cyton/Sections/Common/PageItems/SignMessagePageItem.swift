//
//  SignMessagePageItem.swift
//  Cyton
//
//  Created by James Chen on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

class SignMessagePageItem: BLTNPageItem {
    static func create() -> SignMessagePageItem {
        let item = SignMessagePageItem(title: "DApp.Browser.confirmSign".localized())
        item.appearance = PageItemAppearance.default
        item.actionButtonTitle = "Common.confirm".localized()
        return item
    }
}
