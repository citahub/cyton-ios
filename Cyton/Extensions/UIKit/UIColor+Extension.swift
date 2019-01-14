//
//  UIColor+Extension.swift
//  Cyton
//
//  Created by James Chen on 2018/11/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        let v = hexString.map { String($0) } + Array(repeating: "0", count: max(6 - hexString.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    var hex: String {
        let components = cgColor.components!
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])

        return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
}
