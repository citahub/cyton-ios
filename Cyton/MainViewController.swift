//
//  MainViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        applyStyle()
        addDefaultTokenToRealm()

        viewControllers?[0].title = "DApp.Home".localized()
        viewControllers?[1].title = "Wallet".localized()
        viewControllers?[2].title = "Settings.Title".localized()
    }

    func addDefaultTokenToRealm() {
        guard let walletModel = AppModel.current.currentWallet else {
            return
        }
        DefaultTokenAndChain().addDefaultTokenToWallet(wallet: walletModel)
    }

    private func applyStyle() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "tint_color")!], for: .selected)
        let navigationBarBackImage = UIImage(named: "nav_darkback")!.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = navigationBarBackImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = navigationBarBackImage
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
    }
}
