//
//  UIControl+Extension.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UIControl {
    private static var ExpandAreaAssiciationKey: Int = 0

    @IBInspectable var expandArea: CGFloat {
        set {
            objc_setAssociatedObject(self, &UIControl.ExpandAreaAssiciationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let insetsValue = objc_getAssociatedObject(self, &UIControl.ExpandAreaAssiciationKey) as? NSNumber else { return 0.0 }
            return CGFloat(insetsValue.doubleValue)
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else { return nil }
        guard expandArea > 0 else {
            return super.hitTest(point, with: event)
        }
        let expandRect = CGRect(
            x: bounds.origin.x - expandArea,
            y: bounds.origin.y - expandArea,
            width: bounds.size.width + expandArea * 2,
            height: bounds.size.height + expandArea * 2
        )
        return expandRect.contains(point) ? self : nil
    }
}
