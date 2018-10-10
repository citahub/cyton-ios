//
//  GenerateMnemonicController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class GenerateMnemonicController: UIViewController, NoScreenshot, EnterBackOverlayPresentable {

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
        setupEnterBackOverlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "禁止截屏！", message: "拥有助记词就能完全控制该地址下的资产，建议抄写并放在安全的地方！")
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
