//
//  SuccessPageItem.swift
//  Cyton
//
//  Created by James Chen on 2018/11/19.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

class SuccessPageItem: BLTNPageItem {
    static func create(title: String) -> SuccessPageItem {
        let item = SuccessPageItem(title: title)

        item.appearance = PageItemAppearance.default
        item.image = UIImage(named: "success")
        item.actionButtonTitle = "Common.confirm".localized()
        item.isDismissable = false

        return item

    }
}
