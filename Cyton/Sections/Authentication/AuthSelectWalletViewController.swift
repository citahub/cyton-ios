//
//  AuthSelectWalletViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/9.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift

protocol AuthSelectWalletViewControllerDelegate: class {
    func selectWalletController(_ controller: AuthSelectWalletViewController, didSelectWallet model: WalletModel)
}

class AuthSelectWalletViewController: UITableViewController {
    var wallets = List<WalletModel>()
    weak var delegate: AuthSelectWalletViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Authentication.selectWallet".localized()
        wallets = AppModel.current.wallets
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AuthSelectWalletTableViewCell.self)) as! AuthSelectWalletTableViewCell
        let wallet = wallets[indexPath.row]
        cell.iconImageView.image = wallet.icon.image
        cell.nameLabel.text = wallet.name
        cell.addressLabel.text = wallet.address
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectWalletController(self, didSelectWallet: wallets[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

class AuthSelectWalletTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
}
