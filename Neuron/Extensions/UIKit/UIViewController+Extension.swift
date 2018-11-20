//
//  UIViewController+Extension.swift
//  Neuron
//
//  Created by XiaoLu on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UIViewController {
    var safeAreaFrame: CGRect {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.layoutFrame
        } else {
            return view.frame
        }
    }
}
