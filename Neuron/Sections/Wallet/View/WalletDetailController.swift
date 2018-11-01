//
//  WalletDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SCLAlertView

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
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("请输入钱包密码")
        txt.isSecureTextEntry = true
        alert.addButton("确定") {
            txt.resignFirstResponder()
            self.deleteWallet(password: txt.text!)
        }
        alert.addButton("取消") {
        }
        alert.showEdit("删除钱包", subTitle: "请确保您已经做好钱包备份", colorStyle: 0x2e4af2, colorTextButton: 0xFFFFFF)
    }

    private func deleteWallet(password: String) {
        // TODO: wrap realm and keystore operation as an atom transaction
        let wallet = walletModel.wallet!
        Toast.showHUD()
        do {
            try WalletManager.default.deleteWallet(wallet: wallet, password: password)
            try WalletRealmTool.realm.write {
                if appModel.wallets.count == 1 {
                    WalletRealmTool.realm.deleteAll()
                    NotificationCenter.default.post(name: .allWalletsDeleted, object: nil)
                } else {
                    appModel.currentWallet = appModel.wallets.filter({ (model) -> Bool in
                        return model.address.removeHexPrefix().lowercased() != wallet.address.removeHexPrefix().lowercased()
                    }).first!
                    WalletRealmTool.realm.delete(walletModel)
                }
            }
            Toast.hideHUD()
            Toast.showToast(text: "删除成功")
            navigationController?.popToRootViewController(animated: true)
        } catch {
            Toast.hideHUD()
            return Toast.showToast(text: "密码错误")
        }
    }

    private func exportKeystore(password: String) {
        do {
            let wallet = WalletRealmTool.getCurrentAppModel().currentWallet!.wallet!
            guard case .succeed(result: let keystore) = WalletManager.default.exportKeystore(wallet: wallet, password: password) else {
                throw ExportError.invalidPassword
            }
            let exportController = ExportKeystoreController(nibName: "ExportKeystoreController", bundle: nil)
            exportController.keystoreString = keystore
            self.navigationController?.pushViewController(exportController, animated: true)
        } catch {
            Toast.showToast(text: "密码错误")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                didChangeWalletName()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert = SCLAlertView(appearance: appearance)
                let txt = alert.addTextField("请输入钱包密码")
                txt.isSecureTextEntry = true
                alert.addButton("确定") {
                    txt.resignFirstResponder()
                    self.exportKeystore(password: txt.text!)
                }
                alert.addButton("取消") {
                }
                alert.showEdit("导出keystore", subTitle: "", colorStyle: 0x2e4af2, colorTextButton: 0xFFFFFF)
            }
        }
    }

    func didChangeWalletName() {
        // Add a text field
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("请输入钱包名字")
        alert.addButton("确定") {
            if case .invalid(let reason) = WalletNameValidator.validate(walletName: txt.text ?? "") {
                Toast.showToast(text: reason)
                return
            }
            try! WalletRealmTool.realm.write {
                self.walletModel.name = txt.text!
                self.walletNameLabel.text = txt.text
            }
        }
        alert.addButton("取消") {
        }
        alert.showEdit("修改钱包名称", subTitle: "", colorStyle: 0x2e4af2, colorTextButton: 0xFFFFFF)
    }
}
