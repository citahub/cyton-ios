//
//  SelectWalletController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

protocol SelectWalletControllerDelegate: class {
    func selectWalletController(_ controller: SelectWalletController, didSelectWallet model: WalletModel)
}

class SelectWalletController: UITableViewController {
    @IBOutlet private weak var addWalletButton: UIButton!

    var appModel = AppModel()
    weak var delegate: SelectWalletControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didGetWalletData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SwitchWallet.title".localized()
        addWalletButton.setTitle("  " + "Wallet.addWallet".localized(), for: .normal)
        didGetWalletData()

        addWalletButton.layoutIfNeeded()
        let border = CAShapeLayer()
        border.strokeColor = UIColor(named: "weak_1_color")?.cgColor
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: addWalletButton.bounds, cornerRadius: 6).cgPath
        border.frame = addWalletButton.bounds
        border.lineWidth = 1.0
        border.lineCap = .square
        border.lineDashPattern = [4, 4]
        addWalletButton.layer.addSublayer(border)
    }

    func didGetWalletData() {
        appModel = AppModel.current
        tableView.reloadData()
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
        cell.iconImageView.image = walletModel.icon.image
        cell.nameLabel.text = walletModel.name
        cell.addressLabel.text = walletModel.address
        if appModel.currentWallet?.address == walletModel.address {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let walletModel = appModel.wallets[indexPath.section]
        let realm = try! Realm()
        try! realm.write {
            appModel.currentWallet = walletModel
        }
        delegate?.selectWalletController(self, didSelectWallet: walletModel)
        navigationController?.popViewController(animated: true)
    }
}
