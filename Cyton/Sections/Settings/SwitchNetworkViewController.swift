//
//  SwitchNetworkViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class SwitchNetworkViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings.SwitchNetwork.Title".localized()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EthereumNetwork.NetworkType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchNetwork") as! SwitchNetworkTableViewCell
        let network = EthereumNetwork.NetworkType.allCases[indexPath.row]
        cell.networkLabel.text = network.chainName
        if EthereumNetwork().networkType == network {
            cell.selectImage.isHidden = false
        } else {
            cell.selectImage.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        EthereumNetwork().networkType = EthereumNetwork.NetworkType.allCases[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
}
