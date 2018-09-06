//
//  BaseNavigationController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

extension UINavigationBar {
    var isDarkStyle: Bool {
        set {
            if newValue {
                titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
                barTintColor = AppColor.newThemeColor
                tintColor = .white
                barStyle = .black
                shadowImage = UIImage()
            } else {
                titleTextAttributes = [NSAttributedStringKey.foregroundColor: ColorFromString(hex: "#242b43")]
                barTintColor = .white
                tintColor = ColorFromString(hex: "#333333")
                barStyle = .default
                shadowImage = nil
            }
        }
        get {
            return barStyle == .black
        }
    }
}

class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = viewControllers.count > 0
        super.pushViewController(viewController, animated: animated)
    }
}
