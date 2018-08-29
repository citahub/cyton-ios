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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导入钱包"
    }
}
