//
//  BaseNavigationController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    enum Style {
        case home
        case inner
    }

    var style = Style.home {
        didSet {
            applyStyle()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyStyle()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 0 {
            viewController.hidesBottomBarWhenPushed = false
            style = .home
        } else {
            viewController.hidesBottomBarWhenPushed = true
            style = .inner
        }
        super.pushViewController(viewController, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let viewController =  super.popViewController(animated: animated)
        style = viewControllers.count <= 1 ? .home : .inner
        return viewController
    }

    private func applyStyle() {
        if style == .home {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            navigationBar.barTintColor = ColorFromString(hex: newThemeColor)
            navigationBar.barStyle = .black
        } else {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: ColorFromString(hex: "#242b43")]
            navigationBar.barTintColor = .white
            navigationBar.barStyle = .default
        }
    }
}
