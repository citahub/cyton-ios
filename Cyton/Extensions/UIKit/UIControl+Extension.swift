//
//  UIControl+Extension.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UIControl {
    private static var expandAreaAssiciationKey: Int = 0
    private static var expandAreaInsetsAssiciationKey: Int = 0

    @IBInspectable var expandArea: CGFloat {
        set {
            expandAreaInsets = UIEdgeInsets(top: newValue, left: newValue, bottom: newValue, right: newValue)
        }
        get {
            return expandAreaInsets.left
        }
    }
    var expandAreaInsets: UIEdgeInsets {
        set {
            objc_setAssociatedObject(self, &UIControl.expandAreaInsetsAssiciationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let insetsValue = objc_getAssociatedObject(self, &UIControl.expandAreaInsetsAssiciationKey) else { return UIEdgeInsets.zero }
            guard let insets = insetsValue as? UIEdgeInsets else { return UIEdgeInsets.zero }
            return insets
        }
    }
    @IBInspectable var expandLeft: CGFloat {
        set {
            let insets = expandAreaInsets
            expandAreaInsets = UIEdgeInsets(top: insets.top, left: newValue, bottom: insets.bottom, right: insets.right)
        }
        get {
            return expandAreaInsets.left
        }
    }
    @IBInspectable var expandRight: CGFloat {
        set {
            let insets = expandAreaInsets
            expandAreaInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom, right: newValue)
        }
        get {
            return expandAreaInsets.right
        }
    }
    @IBInspectable var expandTop: CGFloat {
        set {
            let insets = expandAreaInsets
            expandAreaInsets = UIEdgeInsets(top: newValue, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
        get {
            return expandAreaInsets.top
        }
    }
    @IBInspectable var expandBottom: CGFloat {
        set {
            let insets = expandAreaInsets
            expandAreaInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: newValue, right: insets.right)
        }
        get {
            return expandAreaInsets.bottom
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if expandAreaInsets != UIEdgeInsets.zero {
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else { return nil }
        let insets = expandAreaInsets
        guard insets != UIEdgeInsets.zero else {
            return super.hitTest(point, with: event)
        }
        let expandRect = CGRect(
            x: bounds.origin.x - insets.left,
            y: bounds.origin.y - insets.top,
            width: bounds.size.width + insets.left + insets.right,
            height: bounds.size.height + insets.top + insets.bottom
        )
        return expandRect.contains(point) ? self : nil
    }
}
