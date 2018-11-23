//
//  UIStyle.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

struct ScreenSize {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}

struct StatusBar {
    static let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    static let navigationBarHeight: CGFloat = 44.0
}
