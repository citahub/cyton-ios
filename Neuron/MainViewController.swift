//
//  MainViewController.swift
//  Neuron
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

        determineWalletViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(determineWalletViewController), name: .allWalletsDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(determineWalletViewController), name: .firstWalletCreated, object: nil)

        addNativeTokenMsgToRealm()
    }

    // get native token for nervos  'just temporary'
    func addNativeTokenMsgToRealm() {
        let appModel = AppModel.current
        let ethModel = TokenModel()
        ethModel.address = ""
        ethModel.chainId = NativeChainId.ethMainnetChainId
        ethModel.chainName = ""
        ethModel.decimals = NativeDecimals.nativeTokenDecimals
        ethModel.iconUrl = ""
        ethModel.isNativeToken = true
        ethModel.name = "ethereum"
        ethModel.symbol = "ETH"
        let realm = try! Realm()
        try? realm.write {
            WalletRealmTool.addTokenModel(tokenModel: ethModel)
            if !appModel.nativeTokenList.contains(ethModel) {
                appModel.nativeTokenList.append(ethModel)
                WalletRealmTool.addObject(appModel: appModel)
            }
        }

        // Add mba token
        DispatchQueue.global().async {
            let mbaHost = "http://testnet.mba.cmbchina.biz:1337"
            do {
                let metaData = try AppChainNetwork.appChain(url: URL(string: mbaHost)!).rpc.getMetaData()
                let realm = try Realm()
                let appModel = realm.objects(AppModel.self).first!
                guard !appModel.nativeTokenList.contains(where: {
                    $0.chainId == metaData.chainId && $0.chainHosts == mbaHost && $0.symbol == metaData.tokenSymbol
                }) else { return }

                let tokenModel = TokenModel()
                tokenModel.chainId = metaData.chainId
                tokenModel.chainName = metaData.chainName
                tokenModel.symbol = metaData.tokenSymbol
                tokenModel.iconUrl = metaData.tokenAvatar
                tokenModel.name = metaData.tokenName
                tokenModel.chainHosts = mbaHost
                tokenModel.isNativeToken = true
                try realm.write {
                    appModel.nativeTokenList.append(tokenModel)
                }
            } catch {
            }
        }
    }

    private func applyStyle() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "tint_color")], for: .selected)

        let navigationBarBackImage = UIImage(named: "nav_darkback")!.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = navigationBarBackImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = navigationBarBackImage

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)

        UINavigationBar.fixSpace
        UINavigationItem.fixSpace
    }

    @objc
    private func determineWalletViewController() {
        let walletViewController: UIViewController
        if AppModel.current.wallets.isEmpty {
            walletViewController = UIStoryboard(name: "AddWallet", bundle: nil).instantiateViewController(withIdentifier: "AddWallet")
        } else {
            walletViewController = UIStoryboard(name: "Wallet", bundle: nil).instantiateInitialViewController()!
        }
        (viewControllers![1] as! BaseNavigationController).viewControllers = [walletViewController]
    }
}
