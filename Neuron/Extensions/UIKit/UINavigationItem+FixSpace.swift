//
//  UINavigationItem+FixSpace.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UINavigationItem {
    static let fixSpace: Void = {
        swizzedMethod(
            originalSelector: #selector(setLeftBarButtonItems(_:animated:)),
            swizzledSelector: #selector(swizzle_setLeftBarButtonItems(_:animated:))
        )
        swizzedMethod(
            originalSelector: NSSelectorFromString("setLeftBarButtonItem:"),
            swizzledSelector: #selector(swizzle_setLeftBarButtonItem(_:))
        )
    }()

    @objc func swizzle_setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        if var items = items {
            let fixSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixSpaceBarButtonItem.width = -10
            items.insert(fixSpaceBarButtonItem, at: 0)
            swizzle_setLeftBarButtonItems(items, animated: animated)
        } else {
            swizzle_setLeftBarButtonItems(items, animated: animated)
        }
    }

    @objc func swizzle_setLeftBarButtonItem(_ item: UIBarButtonItem) {
        setLeftBarButtonItems([item], animated: false)
    }

    func fixSpace() {
        setLeftBarButtonItems(leftBarButtonItems, animated: false)
    }
}
