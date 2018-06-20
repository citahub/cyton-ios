//
//  MainViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//
//  设置整个tabbar容器

import UIKit

class MainViewController: UITabBarController,UITabBarControllerDelegate {

    private var subController1 = SubController1()
    private var subController2 = SubController2()
    private var subController3 = SubController3()
    private var subController4 = SubController4()
    private var addWallet = AddWalletController()
    
    var nav1:BaseNavigationController?
    var nav2:BaseNavigationController?
    var nav3:BaseNavigationController?
    var nav4:BaseNavigationController?
    var nav5:BaseNavigationController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        addNotify()
        self.initTabbarItems()
    }
    
    //添加通知监听
    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeSubViews), name: .changeTabbr, object: nil)
    }
    
    //初始化tabbar
    public func initTabbarItems(){
        
        let font = UIFont.systemFont(ofSize: 10)
        let normalColor = ColorFromString(hex: "#666666")
        let selectColor = ColorFromString(hex: themeColor)
        
        let normalAttrs:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):normalColor,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : font
        ]
        
        let selectedAttrs : [NSAttributedStringKey:Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : selectColor,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : font
        ]
        
        subController1.tabBarItem = self.getTabbarItem(title: "应用", image: "dapp_off", imageSel: "dapp_on", normalAttrs: normalAttrs, selectedAttrs: selectedAttrs, tag: 0)
        nav1 = BaseNavigationController.init(rootViewController: subController1)
        
//        subController2 = SubController2.init(nibName: "SubController2", bundle: nil)
        subController2.tabBarItem = self.getTabbarItem(title: "钱包", image: "wallet_off", imageSel: "wallet_on", normalAttrs: normalAttrs, selectedAttrs: selectedAttrs, tag: 1)
        nav2 = BaseNavigationController.init(rootViewController: subController2)
        
        addWallet.tabBarItem = self.getTabbarItem(title: "钱包", image: "wallet_off", imageSel: "wallet_on", normalAttrs: normalAttrs, selectedAttrs: selectedAttrs, tag: 4)
        nav5 = BaseNavigationController.init(rootViewController: addWallet)
        
        subController3.tabBarItem = self.getTabbarItem(title: "交易", image: "trade_off", imageSel: "trade_on", normalAttrs: normalAttrs, selectedAttrs: selectedAttrs, tag: 2)
        nav3 = BaseNavigationController.init(rootViewController: subController3)
        
        subController4.tabBarItem = self.getTabbarItem(title: "设置", image: "setting_off", imageSel: "setting_on", normalAttrs: normalAttrs, selectedAttrs: selectedAttrs, tag: 3)
        nav4 = BaseNavigationController.init(rootViewController: subController4)
        
        if WalletRealmTool.isHasWallet() {
            self.viewControllers = [nav1,nav2,nav3,nav4] as? [UIViewController]
        }else{
            self.viewControllers = [nav1,nav5,nav3,nav4] as? [UIViewController]
        }
    }
    
    @objc func didChangeSubViews(){
        if WalletRealmTool.isHasWallet() {
            self.viewControllers = [nav1,nav2,nav3,nav4] as? [UIViewController]
        }else{
            self.viewControllers = [nav1,nav5,nav3,nav4] as? [UIViewController]
        }
    }
    
    //创建底部的tab切换按钮
    func getTabbarItem(title:String,image:String,imageSel:String,normalAttrs:[NSAttributedStringKey:Any],selectedAttrs:[NSAttributedStringKey:Any],tag:Int) -> UITabBarItem {
        
        let barItem = UITabBarItem()
        barItem.title = title
        barItem.tag = tag
        
        barItem.titlePositionAdjustment = UIOffsetMake(0, -4)
        barItem.setTitleTextAttributes(normalAttrs, for: .normal)
        barItem.setTitleTextAttributes(selectedAttrs, for: .selected)
        barItem.image = UIImage(named:image)?.withRenderingMode(.alwaysOriginal)
        barItem.selectedImage = UIImage(named:imageSel)?.withRenderingMode(.alwaysOriginal)
        
        
        return barItem
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
