//
//  FixSwipeBackable.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol FixSwipeBackable: UIGestureRecognizerDelegate {
}

extension FixSwipeBackable where Self: UIViewController {
    func fixSwipeBack() -> UIPanGestureRecognizer {
        let internalTargets = navigationController?.interactivePopGestureRecognizer?.value(forKey: "targets") as! [NSObject]
        let internalTarget = internalTargets.first?.value(forKey: "target")
        let internalAction = NSSelectorFromString("handleNavigationTransition:")
        let panGestureRecognizer = UIPanGestureRecognizer(target: internalTarget, action: internalAction)
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let translation = gestureRecognizer.translation(in: view)
        return translation.x > 0
    }
}
