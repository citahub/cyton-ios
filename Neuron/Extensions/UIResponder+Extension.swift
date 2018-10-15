//
//  UIResponder+Extension.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/9.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

private var UIResponderEventStrategyAssiciationKey: Int = 0

extension UIResponder {
    var eventStrategy: [String: Selector] {
        get {
            var dict = objc_getAssociatedObject(self, &UIResponderEventStrategyAssiciationKey) as? [String: Selector]
            if dict == nil {
                dict = [:]
                objc_setAssociatedObject(self, &UIResponderEventStrategyAssiciationKey, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return dict!
        }
        set {
            objc_setAssociatedObject(self, &UIResponderEventStrategyAssiciationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func routerEvent(with eventName: String, userInfo: Any?) {
        if let action = eventStrategy[eventName] {
            if NSStringFromSelector(action).hasSuffix(":") {
                perform(action, with: userInfo)
            } else {
                perform(action)
            }
        } else {
            next?.routerEvent(with: eventName, userInfo: userInfo)
        }
    }

    func registerEventStrategy(with eventName: String, action: Selector) {
        eventStrategy[eventName] = action
    }
}
