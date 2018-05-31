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
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidAppear(animated)
        if self.navigationController?.viewControllers[0] == self {
            self.hidesBottomBarWhenPushed = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBarStyle()
    }
    
    func setUpNavigationBarStyle(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navigation_back"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedStringKey.foregroundColor:ColorFromString(hex: "#ffffff")]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage.init()

    }
    
    override func customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        let btn:UIButton = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "nav_back"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
//        btn.sizeToFit()
        btn.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem.init(customView: btn)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
