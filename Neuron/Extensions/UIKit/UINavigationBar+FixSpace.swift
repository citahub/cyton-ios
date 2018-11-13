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
        layoutMargins = .zero
        for view in subviews {
            if NSStringFromClass(view.classForCoder).contains("ContentView") {
                view.layoutMargins = UIEdgeInsets.zero
            }
        }
    }
}
