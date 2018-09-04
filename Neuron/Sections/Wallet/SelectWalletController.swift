//
//  SelectWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol SelectWalletControllerDelegate: class {
    func selectWalletController(_ controller: SelectWalletController, model: WalletModel)
}

class SelectWalletController: UITableViewController {
    var appModel = AppModel()
    weak var delegate: SelectWalletControllerDelegate?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didGetWalletData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didGetWalletData()
    }

    func didGetWalletData() {
        appModel = WalletRealmTool.getCurrentAppmodel()
    }

    @IBAction func addWalletAction(_ sender: UIButton) {
        let addWalletController = UIStoryboard(name: "AddWallet", bundle: nil).instantiateViewController(withIdentifier: "AddWallet")
        navigationController?.pushViewController(addWalletController, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return appModel.wallets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchWalletCell") as! WalletTableViewCell
        let walletModel = appModel.wallets[indexPath.section]
        cell.iconImageView.image = UIImage(data: walletModel.iconData)
        cell.nameLabel.text = walletModel.name
        cell.addressLabel.text = walletModel.address
        if appModel.currentWallet?.address == walletModel.address {
            cell.selectStatus = true
        } else {
            cell.selectStatus = false
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let walletModel = appModel.wallets[indexPath.section]
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
        }
        delegate?.selectWalletController(self, model: walletModel)
        dismiss(animated: true, completion: nil)
    }
}
