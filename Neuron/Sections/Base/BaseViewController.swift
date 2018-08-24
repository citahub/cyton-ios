//
//  BaseViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = true
        if navigationController?.viewControllers[0] == self {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.viewControllers[0] != self {
            UIApplication.shared.statusBarStyle = .default
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        hidesBottomBarWhenPushed = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidAppear(animated)
        if navigationController?.viewControllers[0] == self {
            hidesBottomBarWhenPushed = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBarStyle()
    }

    func setUpNavigationBarStyle() {
        if navigationController?.viewControllers[0] == self {
            navigationController?.navigationBar.barTintColor = ColorFromString(hex: newThemeColor)
            navigationController?.navigationBar.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: ColorFromString(hex: "#ffffff")]
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            navigationController?.navigationBar.barTintColor = ColorFromString(hex: "#ffffff")
            navigationController?.navigationBar.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: ColorFromString(hex: "#242b43")]
            UIApplication.shared.statusBarStyle = .default
        }

        navigationController?.navigationBar.isTranslucent = false
    }

    override func customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        let btn: UIButton = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        btn.addTarget(target, action: action, for: .touchUpInside)
        if navigationController?.viewControllers[0] == self {
            btn.setImage(UIImage(named: "nav_back"), for: .normal)
        } else {
            btn.setImage(UIImage(named: "nav_darkback"), for: .normal)
        }
        return UIBarButtonItem(customView: btn)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
