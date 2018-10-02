//
//  NeuLoad.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import Toast_Swift

struct Toast {
    private static var loadingView = ToastActivityView.loadFromNib()

    static func showToast(text: String) {
        ToastManager.shared.style.messageFont = UIFont.systemFont(ofSize: 13)
        ToastManager.shared.position = .center
        UIApplication.shared.keyWindow?.makeToast(text, duration: 2.0, style: ToastManager.shared.style)
    }

    static func hideToast() {
        UIApplication.shared.keyWindow?.hideAllToasts()
    }

    static func showHUD(text: String? = nil) {
        loadingView.text = text
        rootView?.isUserInteractionEnabled = false
        rootView?.showToast(loadingView, duration: 60, position: .center) // Do not hide until 60 secs
    }

    static func hideHUD() {
        rootView?.isUserInteractionEnabled = true
        rootView?.hideToast(loadingView)
    }

    private static var rootView: UIView? {
        return (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
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
