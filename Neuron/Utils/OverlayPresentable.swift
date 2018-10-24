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
        overlay.frame = view.bounds
        view.addSubview(overlay)
    }

    func removeOverlay() {
        overlay.removeFromSuperview()
    }
}

// MARK: - Error

class ErrorOverlayViewController: UIViewController {
    enum Style {
        case blank
        case networkFail
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    var style: Style = .networkFail {
        didSet {
            _ = view // load view
            if style == .networkFail {
                imageView.image = UIImage(named: "fail_icon")
                messageLabel.text = "网络错误，请稍后再试"
                refreshButton.isHidden = false
            } else {
                imageView.image = UIImage(named: "blank_icon")
                messageLabel.text = "空空如也"
                refreshButton.isHidden = true
            }
        }
    }
    var refreshBlock: (() -> Void)?

    @IBAction func refresh(_ sender: Any) {
        refreshBlock?()
    }
}

protocol ErrorOverlayPresentable: OverlayPresentable {
    var errorOverlayRefreshBlock: (() -> Void)? { get set }

    func showBlankOverlay()

    func showNetworkFailOverlay()
}

private var ErrorOverlayControllerAssociationKey = 0

extension ErrorOverlayPresentable {
    fileprivate var errorOverlaycontroller: ErrorOverlayViewController {
        if let controller = objc_getAssociatedObject(self, &ErrorOverlayControllerAssociationKey) as? ErrorOverlayViewController {
            return controller
        }
        let controller: ErrorOverlayViewController = UIStoryboard(name: .overlay).instantiateViewController()
        objc_setAssociatedObject(self, &ErrorOverlayControllerAssociationKey, controller, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return controller
    }
    var overlay: UIView {
        return errorOverlaycontroller.view
    }
    var errorOverlayRefreshBlock: (() -> Void)? {
        get {
            return errorOverlaycontroller.refreshBlock
        }
        set {
            errorOverlaycontroller.refreshBlock = newValue
        }
    }

    func showBlankOverlay() {
        errorOverlaycontroller.style = .blank
        showOverlay()
    }

    func showNetworkFailOverlay() {
        errorOverlaycontroller.style = .networkFail
        showOverlay()
    }
}

// MARK: - EnterBack

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

    func showOverlay() {
        view.window?.addSubview(overlay)
    }
}
