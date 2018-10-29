//
//  MessageSignShowViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol MessageSignShowViewControllerDelegate: class {
    func clickAgreeButton()
    func clickRejectButton()
}

class MessageSignShowViewController: UIViewController {
    var dataText = "" {
        didSet {
            dataTextView.text = dataText
        }
    }
    @IBOutlet weak var icomImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var dataTextView: UITextView!

    weak var delegate: MessageSignShowViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tabbedButtonView.buttonTitles = ["HEX", "UTF8"]
        tabbedButtonView.delegate = self
        setUIData()
    }

    func setUIData() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        nameLabel.text = walletModel.name
        addressLabel.text = walletModel.address
        icomImageView.image = UIImage(data: walletModel.iconData)
    }

    @IBAction func agreeAction(_ sender: UIButton) {
        delegate?.clickAgreeButton()
    }

    @IBAction func rejectAction(_ sender: UIButton) {
        delegate?.clickRejectButton()
    }
}

extension MessageSignShowViewController: TabbedButtonsViewDelegate {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        if index == 0 {
            dataTextView.text = dataText
        } else {
            dataTextView.text = String(decoding: Data.fromHex(dataText)!, as: UTF8.self)
        }
    }
}
