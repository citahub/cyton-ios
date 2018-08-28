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
    var walletModel = WalletModel()
    var mnemonicStr = "" {
        didSet {
        }
    }
    @IBOutlet weak var mnemonic: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mnemonic.text = mnemonicStr
        title = "备份助记词"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmMnemonic" {
            let sureMnemonicViewController = segue.destination as! SureMnemonicViewController
            sureMnemonicViewController.mnemonic = mnemonicStr
            sureMnemonicViewController.password = password
            sureMnemonicViewController.walletModel = walletModel
        }
    }
}
