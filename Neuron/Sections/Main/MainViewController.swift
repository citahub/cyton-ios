//
//  MainViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    private var dAppNavigationController: BaseNavigationController!
    private var walletNavigationController: BaseNavigationController!
    private var settingsNavigationController: BaseNavigationController!

    //temp
    let sub2ViewModel = SubController2ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        initTabbarItems()
        determineWalletViewController()
        viewControllers = [dAppNavigationController, walletNavigationController, settingsNavigationController]
        NotificationCenter.default.addObserver(self, selector: #selector(determineWalletViewController), name: .changeTabbar, object: nil)

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
                print(tModel.description)
            } else {
                NeuLoad.showToast(text: (error?.localizedDescription)!)
            }
            group.leave()
        }

        let appModel = WalletRealmTool.getCurrentAppmodel()
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
        ethModel.chainId = ETH_MainNetChainId
        ethModel.chainName = ""
        ethModel.decimals = nativeTokenDecimals
        ethModel.iconUrl = ""
        ethModel.isNativeToken = true
        ethModel.name = "ethereum"
        ethModel.symbol = "ETH"
        ethModel.chainidName = ETH_MainNetChainId + ""
        try? WalletRealmTool.realm.write {
            WalletRealmTool.realm.add(ethModel, update: true)
            if !appModel.nativeTokenList.contains(ethModel) {
                appModel.nativeTokenList.append(ethModel)
                WalletRealmTool.addObject(appModel: appModel)
            }
        }
    }

    public func initTabbarItems() {
        let dAppViewController = DappViewController()
        dAppViewController.tabBarItem = createTabbarItem(title: "应用", image: "dapp_off", imageSel: "dapp_on")
        dAppNavigationController = BaseNavigationController(rootViewController: dAppViewController)

        walletNavigationController = BaseNavigationController()

        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = createTabbarItem(title: "设置", image: "setting_off", imageSel: "setting_on")
        settingsNavigationController = BaseNavigationController(rootViewController: settingsViewController)
    }

    @objc
    private func determineWalletViewController() {
        let walletViewController: UIViewController
        if WalletRealmTool.hasWallet() {
            walletViewController = WalletViewController()
        } else {
            walletViewController = AddWalletController()
        }
        walletViewController.tabBarItem = createTabbarItem(title: "钱包", image: "wallet_off", imageSel: "wallet_on")
        walletNavigationController.viewControllers = [walletViewController]
    }

    private func createTabbarItem(title: String, image: String, imageSel: String) -> UITabBarItem {
        let barItem = UITabBarItem()
        barItem.title = title

        barItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)

        barItem.setTitleTextAttributes([
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): ColorFromString(hex: "#666666"),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 10)
        ], for: .normal)
        barItem.setTitleTextAttributes([
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): ColorFromString(hex: themeColor),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 10)
        ], for: .selected)

        barItem.image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        barItem.selectedImage = UIImage(named: imageSel)?.withRenderingMode(.alwaysOriginal)

        return barItem
    }
}
