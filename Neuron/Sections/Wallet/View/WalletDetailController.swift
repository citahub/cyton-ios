//
//  WalletDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class WalletDetailController: UITableViewController {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet var walletIconImageView: UIImageView!
    var appModel = AppModel()
    var walletModel = WalletModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "钱包管理"
        appModel = WalletRealmTool.getCurrentAppModel()
        walletModel = appModel.currentWallet!
        walletAddressLabel.text = walletModel.address
        walletNameLabel.text = walletModel.name
        walletIconImageView.image = UIImage(data: walletModel.iconData)
    }

    @IBAction func didDeleteWallet(_ sender: UIButton) {
        InputTextViewController.viewController(title: "删除钱包", placeholder: "请输入钱包密码", isSecureTextEntry: true, confirmHandler: { (controller, text) in
            let wallet = self.walletModel.wallet!
            Toast.showHUD()
            do {
                try WalletManager.default.deleteWallet(wallet: wallet, password: text)
                try WalletRealmTool.realm.write {
                    if self.appModel.wallets.count == 1 {
                        WalletRealmTool.realm.deleteAll()
                        NotificationCenter.default.post(name: .allWalletsDeleted, object: nil)
                    } else {
                        self.appModel.currentWallet = self.appModel.wallets.filter({ (model) -> Bool in
                            return model.address.removeHexPrefix().lowercased() != wallet.address.removeHexPrefix().lowercased()
                        }).first!
                        WalletRealmTool.realm.delete(self.walletModel)
                    }
                }
                Toast.hideHUD()
                Toast.showToast(text: "删除成功")
                self.navigationController?.popToRootViewController(animated: true)
            } catch let error {
                Toast.hideHUD()
                return Toast.showToast(text: error.localizedDescription)
            }
        }, cancelHandler: { (controller) in
            controller.dismiss()
        }).show(in: self)
    }

    private func exportKeystore() {
        InputTextViewController.viewController(title: "导出keystore", placeholder: "请输入钱包密码", isSecureTextEntry: true, confirmHandler: { (controller, text) in
            do {
                let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
                let keystore = try WalletManager.default.exportKeystore(wallet: wallet, password: text)
                controller.dismiss()
                let exportController = ExportKeystoreController(nibName: "ExportKeystoreController", bundle: nil)
                exportController.keystoreString = keystore
                self.navigationController?.pushViewController(exportController, animated: true)
            } catch let error {
                Toast.showToast(text: error.localizedDescription)
            }
        }, cancelHandler: { (controller) in
            controller.dismiss()
        }).show(in: self)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                didChangeWalletName()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                exportKeystore()
            }
        }
    }

    func didChangeWalletName() {
        InputTextViewController.viewController(title: "修改钱包名称", placeholder: "请输入钱包名称", isSecureTextEntry: false, confirmHandler: { (controller, text) in
            if case .invalid(let reason) = WalletNameValidator.validate(walletName: text) {
                Toast.showToast(text: reason)
                return
            }
            try! WalletRealmTool.realm.write {
                self.walletModel.name = text
            }
            self.walletNameLabel.text = text
            controller.dismiss()
        }, cancelHandler: { (controller) in
            controller.dismiss()
        }).show(in: self)
    }
}
