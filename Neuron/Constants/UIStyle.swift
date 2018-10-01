//
//  UIStyle.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

struct AppColor {
    static let themeColor = ColorFromString(hex: "#2e4af2")
    static let newThemeColor = ColorFromString(hex: "#365fff")
    static let darkBarTintColor = UIColor(red: 17.0 / 255, green: 65.0 / 255, blue: 1, alpha: 1)
    static let lineColor = ColorFromString(hex: "#f1f1f1")
}

struct ScreenSize {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}

//isiPhoneX
public func isiphoneX() -> Bool {
    if ScreenSize.height == 812 {
        return true
    } else {
        return false
    }
}
