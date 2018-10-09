//
//  OverlayPresentable.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/9.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

protocol OverlayPresentable: NSObjectProtocol {
    associatedtype Overlay: UIView
    var overlay: Overlay { get }

    func showOverlay()
    func removeOverlay()
}

extension OverlayPresentable where Self: UIViewController {
    func showOverlay() {
        view.addSubview(overlay)
    }
    func removeOverlay() {
        overlay.removeFromSuperview()
    }
}

protocol EnterBackOverlayPresentable: OverlayPresentable {
    func setupEnterBackOverlay()
}

extension EnterBackOverlayPresentable {
}

extension EnterBackOverlayPresentable where Self: UIViewController {
    var overlay: UIView {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black
        return overlay
    }
    func setupEnterBackOverlay() {
        _ = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { (_) in
        }
    }
    func didEnterBackgroundNotification() {
        debugPrint(#function)
    }
}

extension NSObject {
    func addDeinitTask(block: @escaping DeinitTask.Block) {
        let task = DeinitTask(block: block)
        var key = Date().timeIntervalSince1970
        objc_setAssociatedObject(self, &key, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

class DeinitTask: NSObject {
    typealias Block = () -> Void
    let block: Block
    init(block: @escaping Block) {
        self.block = block
    }
    deinit {
        block()
    }
}
