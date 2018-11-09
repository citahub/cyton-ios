//
//  RequestPaymentViewController.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import EFQRCode

class RequestPaymentViewController: UIViewController {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var QRCode: UIImageView!
    var appModel = AppModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "收款二维码"
        icon.image = UIImage(data: appModel.currentWallet!.iconData!)
        name.text = appModel.currentWallet!.name
        address.text = appModel.currentWallet!.address
        let walletAddress = self.appModel.currentWallet!.address
        DispatchQueue.global().async {
            let imagea = EFQRCode.generate(content: walletAddress)
            DispatchQueue.main.async {
                self.QRCode.image = UIImage(cgImage: imagea!)
            }
        }
    }

    @IBAction func copyAddress(_ sender: UIButton) {
        UIPasteboard.general.string = appModel.currentWallet?.address
        Toast.showToast(text: "地址已经复制到粘贴板")
    }
}
