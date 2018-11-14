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
    @IBOutlet weak var dataLabel: UILabel!
    var dataText = "" {
        didSet {
            dataLabel.text = String(decoding: Data.fromHex(dataText)!, as: UTF8.self)
        }
    }

    weak var delegate: MessageSignShowViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func agreeAction(_ sender: UIButton) {
        delegate?.clickAgreeButton()
    }

    @IBAction func rejectAction(_ sender: UIButton) {
        delegate?.clickRejectButton()
    }
}
