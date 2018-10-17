//
//  SettingsViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    var rowIdentifiers = [
        String(describing: SettingCurrencyTableViewCell.self),
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
            cell.localCurrencyLabel.text = LocalCurrencyService().getLocalCurrencySelect().short
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
        if cell.classForCoder == SettingCurrencyTableViewCell.self {
            let controller: CurrencyViewController = UIStoryboard(name: .settings).instantiateViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else if cell.reuseIdentifier == "SettingAboutUsTableViewCell" {
            let controller: AboutUsTableViewController = UIStoryboard(name: .settings).instantiateViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else if cell.reuseIdentifier == "SettingForumsTableViewCell" {
            let controller: CommonWebViewController = UIStoryboard(name: .settings).instantiateViewController()
            controller.url = URL(string: "https://forums.nervos.org/")
            navigationController?.pushViewController(controller, animated: true)
        } else if cell.reuseIdentifier == "SettingContactCustomerServiceTableViewCell" {
            UIPasteboard.general.string = "Nervos-Neuron"
            Toast.showToast(text: "客服微信已复制")
        }
    }
}
