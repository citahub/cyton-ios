//
//  SwitchNetworkViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class SwitchNetworkViewController: UITableViewController {
    var networks: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings.SwitchNetwork.Title".localized()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EthereumNetwork.EthereumNetworkType.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchNetwork") as! SwitchNetworkTableViewCell
        let network = EthereumNetwork.EthereumNetworkType.allValues[indexPath.row]
        cell.networkLabel.text = network.capitalized
        if EthereumNetwork().currentNetwork.rawValue == network {
            cell.selectImage.isHidden = false
        } else {
            cell.selectImage.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        EthereumNetwork().switchNetwork(EthereumNetwork.EthereumNetworkType.allValues[indexPath.row])
        NotificationCenter.default.post(name: .switchEthNetwork, object: nil)
        navigationController?.popViewController(animated: true)
    }
}
