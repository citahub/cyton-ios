//
//  WalletQRCodeViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/21.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import EFQRCode

class WalletQRCodeViewController: UIViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qrCodeView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appModel = AppModel.current
        iconView.image = UIImage(data: appModel.currentWallet!.iconData!)
        nameLabel.text = appModel.currentWallet!.name
        addressLabel.text = appModel.currentWallet!.address
        let walletAddress = appModel.currentWallet!.address

        DispatchQueue.global().async {
            let imagea = EFQRCode.generate(content: walletAddress)
            DispatchQueue.main.async {
                self.qrCodeView.image = UIImage(cgImage: imagea!)
            }
        }
    }

    @IBAction func copyAddress(_ sender: Any) {
        UIPasteboard.general.string = AppModel.current.currentWallet?.address
        Toast.showToast(text: "地址已经复制到粘贴板")
    }
}
