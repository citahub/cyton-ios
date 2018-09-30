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

    @IBAction func didDeletWallet(_ sender: UIButton) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("请输入钱包密码")
        txt.isSecureTextEntry = true
        alert.addButton("确定") {
            txt.resignFirstResponder()
            if self.walletModel.MD5screatPassword != CryptTools.changeMD5(password: txt.text!) {
                NeuLoad.showToast(text: "旧密码错误")
                return
            } else {
                self.deleteWallet(password: txt.text!)
            }
        }
        alert.addButton("取消") {

        }
        alert.showEdit("删除钱包", subTitle: "请确保您已经做好钱包备份", colorStyle: 0x2e4af2,
                       colorTextButton: 0xFFFFFF)
    }

    func deleteWallet(password: String) {
        let address = walletModel.address
        try! WalletRealmTool.realm.write {
            if appModel.wallets.count == 1 {
                WalletRealmTool.realm.deleteAll()
                NotificationCenter.default.post(name: .allWalletsDeleted, object: self, userInfo: nil)
            } else {
                appModel.currentWallet = appModel.wallets[0]
                WalletRealmTool.realm.delete(walletModel)
            }
        }
        WalletCryptoService.didDelegateWallet(password: password, walletAddress: address)
        NeuLoad.showToast(text: "删除成功")
        navigationController?.popToRootViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                didChangeWalletNmae()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let pCtrl = ChangePasswordController.init(nibName: "ChangePasswordController", bundle: nil)
                navigationController?.pushViewController(pCtrl, animated: true)
            }
            if indexPath.row == 1 {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert = SCLAlertView(appearance: appearance)
                let txt = alert.addTextField("请输入钱包密码")
                txt.isSecureTextEntry = true
                alert.addButton("确定") {
                    txt.resignFirstResponder()
                    if self.walletModel.MD5screatPassword != CryptTools.changeMD5(password: txt.text!) {
                        NeuLoad.showToast(text: "密码错误")
                        return
                    } else {
                        let eCtrl = ExportKeystoreController.init(nibName: "ExportKeystoreController", bundle: nil)
                        eCtrl.password = txt.text!
                        self.navigationController?.pushViewController(eCtrl, animated: true)
                    }
                }
                alert.addButton("取消") {

                }
                alert.showEdit("导出keystore", subTitle: "", colorStyle: 0x2e4af2,
                               colorTextButton: 0xFFFFFF)
            }
        }
    }

    func didChangeWalletNmae() {
        // Add a text field
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("请输入钱包名字")
        alert.addButton("确定") {
            if !WalletTools.checkWalletName(name: txt.text!) && !txt.text!.isEmpty {NeuLoad.showToast(text: "该钱包名称已存在");return} else {
                let nameClean = txt.text?.trimmingCharacters(in: .whitespaces)
                if nameClean?.count == 0 {
                    NeuLoad.showToast(text: "钱包名字不能为空")
                } else if txt.text!.count > 15 {
                    NeuLoad.showToast(text: "钱包名称不能超过15个字符")
                } else {
                    try! WalletRealmTool.realm.write {
                        self.walletModel.name = txt.text!
                        self.walletNameLabel.text = txt.text
                    }
                }
            }
        }
        alert.addButton("取消") {

        }
        alert.showEdit("修改钱包名称", subTitle: "", colorStyle: 0x2e4af2,
                       colorTextButton: 0xFFFFFF)
    }
}
