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
        title = "切换以太坊网络"
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Web3Network.EthereumNetworkType.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchNetwork") as! SwitchNetworkTableViewCell
        let network = Web3Network.EthereumNetworkType.allValues[indexPath.row]
        cell.networkLabel.text = network
        let selectNetwork = Web3Network().getCurrentNetwork()
        if selectNetwork.rawValue == network {
            cell.selectImage.isHidden = false
        } else {
            cell.selectImage.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let network = Web3Network.EthereumNetworkType.allValues[indexPath.row]
        Web3Network().saveSelectNetwork(network)
        NotificationCenter.default.post(name: .switchEthNetwork, object: nil)
        navigationController?.popViewController(animated: true)
    }
}
