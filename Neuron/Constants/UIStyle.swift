//
//  UIStyle.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

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

struct StatusBar {
    static let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    static let navigationBarHeight: CGFloat = 44.0
}

//is bangs screen
public func isBangsScreen() -> Bool {
    guard #available(iOS 11.0, *) else {
        return false
    }
    return UIApplication.shared.windows[0].safeAreaInsets.bottom > 0.0
}
