//
//  UINavigationBar+FixSpace.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UINavigationBar {
    static let fixSpace: Void = {
        if #available(iOS 11.0, *) {
            swizzedMethod(originalSelector: #selector(layoutSubviews), swizzledSelector: #selector(swizzle_layoutSubviews))
        }
    }()

    @objc func swizzle_layoutSubviews() {
        swizzle_layoutSubviews()
        layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        for view in subviews {
            if NSStringFromClass(view.classForCoder).contains("ContentView") {
                view.layoutMargins = UIEdgeInsets(top: view.layoutMargins.top, left: 0, bottom: view.layoutMargins.bottom, right: view.layoutMargins.right)
            }
        }
    }
}
