//
//  MainViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    //temp
    let sub2ViewModel = SubController2ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        applyBarStyle()

        determineWalletViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(determineWalletViewController), name: .allWalletsDeleted, object: nil)

        addNativeTokenMsgToRealm()
    }

    // get native token for nervos  'just temporary'
    func addNativeTokenMsgToRealm() {
        var tModel = TokenModel()
        let group = DispatchGroup()
        group.enter()
        sub2ViewModel.getMateDataForNervos { (tokenModel, error) in
            if error == nil {
                tModel = tokenModel!
            } else {
                Toast.showToast(text: (error?.localizedDescription)!)
            }
            group.leave()
        }

        let appModel = WalletRealmTool.getCurrentAppModel()
        group.notify(queue: .main) {
            try? WalletRealmTool.realm.write {
                WalletRealmTool.realm.add(tModel, update: true)
                if !appModel.nativeTokenList.contains(tModel) {
                    appModel.nativeTokenList.append(tModel)
                }
            }
        }

        let ethModel = TokenModel()
        ethModel.address = ""
        ethModel.chainId = NativeChainId.ethMainnetChainId
        ethModel.chainName = ""
        ethModel.decimals = NaticeDecimals.nativeTokenDecimals
        ethModel.iconUrl = ""
        ethModel.isNativeToken = true
        ethModel.name = "ethereum"
        ethModel.symbol = "ETH"
        ethModel.chainidName = NativeChainId.ethMainnetChainId + ""
        try? WalletRealmTool.realm.write {
            WalletRealmTool.realm.add(ethModel, update: true)
            if !appModel.nativeTokenList.contains(ethModel) {
                appModel.nativeTokenList.append(ethModel)
                WalletRealmTool.addObject(appModel: appModel)
            }
        }
    }

    private func applyBarStyle() {
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColor.newThemeColor], for: .selected)

        let navigationBarBackImage = UIImage(named: "nav_darkback")!.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = navigationBarBackImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = navigationBarBackImage

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
    }

    @objc
    private func determineWalletViewController() {
        let walletViewController: UIViewController
        if WalletRealmTool.hasWallet() {
            walletViewController = UIStoryboard(name: "Wallet", bundle: nil).instantiateInitialViewController()!
        } else {
            walletViewController = UIStoryboard(name: "AddWallet", bundle: nil).instantiateViewController(withIdentifier: "AddWallet")
        }
        (viewControllers![1] as! BaseNavigationController).viewControllers = [walletViewController]
    }
}
