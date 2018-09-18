//
//  ConfirmAmountViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/17.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

protocol ConfirmAmountViewControllerDelegate: class {
    func closePayCoverView()
    func readyToPay()
}

class ConfirmAmountViewController: UITableViewController {
    var amount: String?
    var fromAddress: String?
    var toAddress: String?
    var gas: String?
    weak var delegate: ConfirmAmountViewControllerDelegate?
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        amountLabel.text = amount
        fromAddressLabel.text = fromAddress
        toAddressLabel.text = toAddress
        gasLabel.text = gas
    }

    @IBAction func clickCloseButton(_ sender: UIButton) {
        delegate?.closePayCoverView()
    }

    @IBAction func clickTransferButton(_ sender: UIButton) {
        delegate?.readyToPay()
    }
}
