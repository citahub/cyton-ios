//
//  PageItemAppearance.swift
//  Cyton
//
//  Created by James Chen on 2018/11/19.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

struct PageItemAppearance {
    static var `default`: BLTNItemAppearance = {
        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = 18
        appearance.titleTextColor = UIColor(hex: "2E313E")
        return appearance
    }()
}
