//
//  MessageSignController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class MessageSignController: UIViewController {
    private var messageSignShowViewController: MessageSignShowViewController!
    private var confirmSendViewController: ConfirmSendViewController!
    private var messageSignPageVC: UIPageViewController!

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
        messageSignShowViewController = storyboard!.instantiateViewController(withIdentifier: "messageSignShowViewController") as? MessageSignShowViewController
        confirmSendViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "confirmSendViewController") as? ConfirmSendViewController
//        confirmSendViewController.delegate = self
        messageSignPageVC.setViewControllers([confirmSendViewController], direction: .forward, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dappPageViewController" {
            messageSignPageVC = segue.destination as? UIPageViewController
        }
    }
}
