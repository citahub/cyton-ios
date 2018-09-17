//
//  PayCoverViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/17.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import BigInt

class PayCoverViewController: UIViewController {
    var amount: String!
    var tokenModel = TokenModel()
    var walletAddress: String!
    var toAddress: String!
    var gasCost: String!
    var gasPrice: BigUInt! // nervos token , it's quota.
    var data: Data?
    var contrackAddress: String = ""

    private var confirmPageViewController: UIPageViewController!
    private var confirmAmountViewController: ConfirmAmountViewController!
    private var confirmSendViewController: ConfirmSendViewController!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.frame = CGRect(x: 0, y: ScreenSize.height, width: ScreenSize.width, height: ScreenSize.height)
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
        }, completion: { (_) in
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        confirmAmountViewController = storyboard!.instantiateViewController(withIdentifier: "confirmAmountViewController") as? ConfirmAmountViewController
        confirmSendViewController = storyboard!.instantiateViewController(withIdentifier: "confirmSendViewController") as? ConfirmSendViewController
        confirmPageViewController.setViewControllers([confirmAmountViewController], direction: .forward, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmPageViewController" {
            confirmPageViewController = segue.destination as? UIPageViewController
        }
    }
}
