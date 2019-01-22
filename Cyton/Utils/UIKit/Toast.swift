//
//  NeuLoad.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import Toast_Swift

struct Toast {
    static func showToast(text: String) {
        guard text.lengthOfBytes(using: .utf8) > 0 else { return }
        ToastManager.shared.style.messageFont = UIFont.systemFont(ofSize: 13)
        ToastManager.shared.position = .center
        UIApplication.shared.keyWindow?.makeToast(text, duration: 2.0, style: ToastManager.shared.style)
    }

    static func hideToast() {
        UIApplication.shared.keyWindow?.hideAllToasts()
    }

    static func showHUD(text: String? = nil) {
        let loadingView = ToastActivityView.loadFromNib()
        loadingView.text = text
        keyWindow?.isUserInteractionEnabled = false
        keyWindow?.showToast(loadingView, duration: 60, position: .center) // Do not hide until 60 secs
    }

    static func hideHUD() {
        keyWindow?.isUserInteractionEnabled = true
        keyWindow?.hideAllToasts()
    }

    private static var rootView: UIView? {
        return (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
    }

    private static var keyWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
}

class ToastActivityView: UIView, NibLoadable {
     @IBOutlet private weak var label: UILabel!

    var text: String? {
        didSet {
            label.text = text
            label.isHidden = text == nil || text!.isEmpty
        }
    }
}
