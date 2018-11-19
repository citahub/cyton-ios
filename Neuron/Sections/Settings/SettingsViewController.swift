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
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var ethereumNetworkLabel: UILabel!
    @IBOutlet var authenticationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getDataForUI() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        nameLabel.text = walletModel.name
        addressLabel.text = walletModel.address
        iconImageView.image = UIImage(data: walletModel.iconData)
        currencyLabel.text = LocalCurrencyService.shared.getLocalCurrencySelect().short
        ethereumNetworkLabel.text = EthereumNetwork().currentNetwork.rawValue.capitalized
        authenticationSwitch.isOn = AuthenticationService.shared.isEnable
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDataForUI()
    }

    @IBAction func authenticationSwitchChanged(_ sender: UISwitch) {
        AuthenticationService.shared.setAuthenticationEnable(enable: !AuthenticationService.shared.isEnable) { (result) in
            sender.isOn = result
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            switch indexPath.row {
            case 1:
                UIPasteboard.general.string = "Nervos-Neuron"
                Toast.showToast(text: "客服微信已复制")
            case 2:
                let safariController = SFSafariViewController(url: URL(string: "https://forums.nervos.org/")!)
                self.present(safariController, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}
