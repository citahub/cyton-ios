//
//  NeuronMacro.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

//theme color
let themeColor = "#2e4af2"
let newThemeColor = "#365fff"
let lineColor = "#f1f1f1"
let darkBarTintColor = UIColor(red: 17.0 / 255, green: 65.0 / 255, blue: 1, alpha: 1)

/// Screen height
let ScreenH = UIScreen.main.bounds.height
/// screen width
let ScreenW = UIScreen.main.bounds.width

//isiPhoneX
public func isiphoneX() -> Bool {
    if UIScreen.main.bounds.height == 812 {
        return true
    } else {
        return false
    }
}
