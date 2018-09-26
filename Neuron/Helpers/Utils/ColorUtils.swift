//
//  ColorUtils.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

/*
 * 16进制颜色
 * author:xiaolu
 */
public func ColorFromString (hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    if cString.hasPrefix("#") {
        cString = (cString as NSString).substring(from: 1)
    }
    let rString = (cString as NSString).substring(to: 2)
    let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
    let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
    var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}

/// 计算lable的高度和宽度方法
///
/// - Parameters:
///   - text: text description
///   - font: font description
///   - maxSize: maxSize description
/// - Returns: return value description
public func textSize(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
    return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil).size
}
