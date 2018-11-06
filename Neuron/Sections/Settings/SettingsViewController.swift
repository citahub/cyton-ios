//
//  SettingsViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UITableViewController {
    var rowIdentifiers = [
        String(describing: SettingCurrencyTableViewCell.self),
        "SettingSwitchEthereumNetwork",
        String(describing: SettingAuthenticationTableViewCell.self),
        "SettingAboutUsTableViewCell",
        "SettingForumsTableViewCell",
        "SettingContactCustomerServiceTableViewCell"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        if !AuthenticationService.shared.isValid {
            rowIdentifiers.remove(at: 1)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @IBAction func authenticationSwitchChanged(_ sender: UISwitch) {
        AuthenticationService.shared.setAuthenticationEnable(enable: !AuthenticationService.shared.isEnable) { (result) in
            sender.isOn = result
        }
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowIdentifiers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowIdentifiers[indexPath.row])!
        if let cell = cell as? SettingCurrencyTableViewCell {
            if cell.reuseIdentifier == "SettingCurrencyTableViewCell" {
                cell.localCurrencyLabel.text = LocalCurrencyService.shared.getLocalCurrencySelect().short
            } else if cell.reuseIdentifier == "SettingSwitchEthereumNetwork" {
                cell.localCurrencyLabel.text = EthereumNetwork().currentNetwork.rawValue.capitalized
            }
        } else if let cell = cell as? SettingAuthenticationTableViewCell {
            cell.authenticationSwitch.isOn = AuthenticationService.shared.isEnable
            cell.authenticationSwitch.addTarget(self, action: #selector(authenticationSwitchChanged), for: .touchUpInside)
        }
        return cell
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if cell.reuseIdentifier == "SettingCurrencyTableViewCell" {
            let controller: CurrencyViewController = UIStoryboard(name: .settings).instantiateViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else if cell.reuseIdentifier == "SettingSwitchEthereumNetwork" {
            let controller = storyboard!.instantiateViewController(withIdentifier: "switchNetworkViewController") as! SwitchNetworkViewController
            navigationController?.pushViewController(controller, animated: true)
        } else if cell.reuseIdentifier == "SettingAboutUsTableViewCell" {
            let controller: AboutUsTableViewController = UIStoryboard(name: .settings).instantiateViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else if cell.reuseIdentifier == "SettingForumsTableViewCell" {
            let safariController = SFSafariViewController(url: URL(string: "https://forums.nervos.org/")!)
            self.present(safariController, animated: true, completion: nil)
        } else if cell.reuseIdentifier == "SettingContactCustomerServiceTableViewCell" {
            UIPasteboard.general.string = "Nervos-Neuron"
            Toast.showToast(text: "客服微信已复制")
        }
    }
}
