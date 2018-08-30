//
//  ImportWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//
//  Should Reconstruction !!!

import UIKit
import RSKPlaceholderTextView

enum SelectButtonStates {
    case keystoreState
    case mnemonicState
    case privateKeyState
}

class ImportWalletController: UIViewController {

    @IBOutlet weak var keystore: UIButton!
    @IBOutlet weak var mnemonic: UIButton!
    @IBOutlet weak var privatekey: UIButton!
    @IBOutlet weak var slider: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导入钱包"
    }
}
