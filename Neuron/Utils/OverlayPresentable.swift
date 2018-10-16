//
//  OverlayPresentable.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/9.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol OverlayPresentable: NSObjectProtocol {
    associatedtype Overlay: UIView
    var overlay: Overlay { get }

    func showOverlay()
    func removeOverlay()
}

extension OverlayPresentable where Self: UIViewController {
    func showOverlay() {
        view.window?.addSubview(overlay)
    }
    func removeOverlay() {
        overlay.removeFromSuperview()
    }
}

protocol EnterBackOverlayPresentable: OverlayPresentable {
    func setupEnterBackOverlay()
}

extension EnterBackOverlayPresentable {
    func setupEnterBackOverlay() {
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [weak self](_) in
            guard let self = self else { return }
            self.showOverlay()
        }
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main, using: { [weak self](_) in
            guard let self = self else { return }
            self.removeOverlay()
        })
        _ = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main, using: { [weak self](_) in
            guard let self = self else { return }
            self.removeOverlay()
        })
    }
}

private var EnterBackOverlayAssiciationKey = 0
extension EnterBackOverlayPresentable where Self: UIViewController {

    var overlay: UIView {
        if let overlay = objc_getAssociatedObject(self, &EnterBackOverlayAssiciationKey) as? UIView {
            return overlay
        }
        let overlay = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        overlay.frame = view.bounds
        objc_setAssociatedObject(self, &EnterBackOverlayAssiciationKey, overlay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return overlay
    }
}
