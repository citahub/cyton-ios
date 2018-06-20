//
//  NeuLoad.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import Toast_Swift

var loadingView = MBProgressHUD()

class NeuLoad: NSObject {
    
    
    /// Toast
    ///
    /// - Parameter text: show text
    static func showToast(text:String)  {
        let wView = UIApplication.shared.keyWindow
//        wView?.makeToast(text, duration: 2.0, position: .center)
        
        let font = UIFont.systemFont(ofSize: 13)
        ToastManager.shared.style.messageFont = font
        ToastManager.shared.position = .center
        wView?.makeToast(text, duration: 2.0, style: ToastManager.shared.style, completion: { (true) in })
        
    }
    
    /// Toast dismiss
    static func dismissToast(){
        let wView = UIApplication.shared.keyWindow
        wView?.hideAllToasts()
    }
    
    
    /// show HUD
    ///
    /// - Parameter text: HUD text
    static func showHUD(text:String){
        let wView = UIApplication.shared.keyWindow
        loadingView = MBProgressHUD.showAdded(to: wView!, animated: true)
        loadingView.label.font = UIFont.systemFont(ofSize: 15)
        loadingView.mode = .indeterminate
        loadingView.label.text = text
    }
    
    /// hide HUD
    static func hidHUD(){
        
        loadingView.hide(animated: true)
//        loadingView.hide(animated: true, afterDelay: 5)
    }
}

