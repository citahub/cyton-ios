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
        super .viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = true
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
        navigationController?.navigationBar.barTintColor = ColorFromString(hex: newThemeColor)
        navigationController?.navigationBar.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: ColorFromString(hex: "#ffffff")]
        navigationController?.navigationBar.isTranslucent = false
    }
    override func customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        let btn: UIButton = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "nav_back"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        btn.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem.init(customView: btn)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
