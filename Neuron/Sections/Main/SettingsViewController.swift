//
//  SettingsViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var fingerprintSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "设置"
        fingerprintSwitch.isOn = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactUs" {
            let webViewController = segue.destination as! CommonWebViewController
            webViewController.urlStr = "https://www.nervos.org/contact"
        }
    }

    @IBAction func fingerprintSwitchChanged(_ sender: Any) {
        let add = UIStoryboard(name: "AddWallet", bundle: nil).instantiateViewController(withIdentifier: "AddWallet")
        navigationController?.pushViewController(add, animated: true)
    }
}
