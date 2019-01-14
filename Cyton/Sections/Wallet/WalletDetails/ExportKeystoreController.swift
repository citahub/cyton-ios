//
//  ExportKeystoreController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ExportKeystoreController: UIViewController, EnterBackOverlayPresentable {
    @IBOutlet private weak var kestoreTextView: UITextView!
    @IBOutlet private weak var copyButton: UIButton!
    var walletModel = WalletModel()
    var keystoreString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Details.exportKeystore".localized()
        copyButton.setTitle("Wallet.Details.ExportKeystore.copy".localized(), for: .normal)
        walletModel = AppModel.current.currentWallet!
        kestoreTextView.text = keystoreString
        setupEnterBackOverlay()
    }

    @IBAction func didClickCopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = keystoreString
        Toast.showToast(text: "Wallet.Details.ExportKeystore.copySuccess".localized())
    }
}
