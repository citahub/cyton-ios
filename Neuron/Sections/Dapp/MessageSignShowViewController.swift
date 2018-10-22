//
//  MessageSignShowViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class MessageSignShowViewController: UIViewController {

    @IBOutlet weak var icomImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var dataTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func agreeAction(_ sender: UIButton) {
    }

    @IBAction func rejectAction(_ sender: UIButton) {
    }

}
