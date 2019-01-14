//
//  AddWalletGuideViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class CreateWalletGuideViewController: UIViewController {
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var createWalletButton: UIButton!
    @IBOutlet private weak var importWalletButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.text = "Wallet.Create.warning".localized()
        descLabel.text = "Wallet.Create.desc".localized()
        createWalletButton.setTitle("Wallet.Create.createWallet".localized(), for: .normal)
        importWalletButton.setTitle("Wallet.Import.title".localized(), for: .normal)
    }
}
