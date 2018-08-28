//
//  GenerateMnemonicController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class GenerateMnemonicController: UIViewController {

    var password = ""
    var mnemonicStr = ""
    var walletModel = WalletModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "备份助记词"
    }
}
