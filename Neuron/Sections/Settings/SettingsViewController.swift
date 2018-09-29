//
//  SettingsViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
//    @IBOutlet weak var fingerprintSwitch: UISwitch!
    @IBOutlet weak var localCurrencyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "设置"
//        fingerprintSwitch.isOn = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        localCurrencyLabel.text = LocalCurrencyService().getLocalCurrencySelect().short
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactUs" {
            let webViewController = segue.destination as! CommonWebViewController
            webViewController.url = URL(string: "https://www.nervos.org/contact")!
        }
    }

    @IBAction func fingerprintSwitchChanged(_ sender: Any) {
    }
}
