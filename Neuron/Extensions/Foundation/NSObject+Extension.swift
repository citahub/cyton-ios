//
//  NSObject+Extension.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension NSObject {
    static func swizzedMethod(originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(self.classForCoder(), originalSelector) else { return }
        guard let swizzledMethod = class_getInstanceMethod(self.classForCoder(), swizzledSelector) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
