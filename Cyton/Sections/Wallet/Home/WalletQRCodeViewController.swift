//
//  WalletQRCodeViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/21.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import EFQRCode
import Social

class WalletQRCodeViewController: UIViewController {
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var qrCodeView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var walletQRCodeDescLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appModel = AppModel.current
        iconView.image = appModel.currentWallet!.icon.image
        nameLabel.text = appModel.currentWallet!.name
        addressLabel.text = appModel.currentWallet!.address
        let walletAddress = appModel.currentWallet!.address

        DispatchQueue.global().async {
            let imagea = EFQRCode.generate(content: walletAddress)
            DispatchQueue.main.async {
                self.qrCodeView.image = UIImage(cgImage: imagea!)
            }
        }
        localization()
    }

    @IBAction func copyAddress(_ sender: Any) {
        UIPasteboard.general.string = AppModel.current.currentWallet?.address
        Toast.showToast(text: "Wallet.QRCode.copySuccess".localized())
    }

    func localization() {
        title = "Wallet.receipt".localized()
        copyButton.setTitle("Wallet.QRCode.copy".localized(), for: .normal)
        walletQRCodeDescLabel.text = "Wallet.QRCode.desc".localized()
    }

    @IBAction func share(_ sender: Any) {
        guard let image = qrCodeView.image else { return }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.excludedActivityTypes = [.markupAsPDF, .mail, .openInIBooks, .print, .addToReadingList, .assignToContact]
        present(controller, animated: true, completion: nil)
    }
}
