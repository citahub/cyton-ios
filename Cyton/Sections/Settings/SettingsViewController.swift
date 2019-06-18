//
//  SettingsViewController.swift
//  Cyton
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

    @IBOutlet weak var currencyTitleLabel: UILabel!
    @IBOutlet weak var touchIdLabel: UILabel!
    @IBOutlet weak var switchEthLabel: UILabel!
    @IBOutlet weak var aboutUsLabel: UILabel!
    @IBOutlet weak var forumLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings.Title".localized()
        currencyTitleLabel.text = "Settings.CurrencyTitle".localized()
        touchIdLabel.text = "Settings.TouchIdTitle".localized()
        switchEthLabel.text = "Settings.SwitchNetwork.Title".localized()
        aboutUsLabel.text = "Settings.About.AboutUs".localized()
        forumLabel.text = "Settings.Forum".localized()
    }

    func getDataForUI() {
        if let walletModel = AppModel.current.currentWallet {
            nameLabel.text = walletModel.name
            addressLabel.text = walletModel.address
            iconImageView.image = walletModel.icon.image
            currencyLabel.text = LocalCurrencyService.shared.getLocalCurrencySelect().short
            ethereumNetworkLabel.text = EthereumNetwork().networkType.chainName
            authenticationSwitch.isOn = AuthenticationService.shared.isEnable
        }
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

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 && !AuthenticationService.shared.isValid {
            cell.isHidden = true
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 && !AuthenticationService.shared.isValid {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            switch indexPath.row {
            case 1:
                let safariController = SFSafariViewController(url: URL(string: "https://talk.citahub.com/")!)
                self.present(safariController, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}
