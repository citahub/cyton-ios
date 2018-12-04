//
//  WalletDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BLTNBoard
import RealmSwift

class WalletDetailController: UITableViewController {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet var walletIconImageView: UIImageView!
    var appModel = AppModel()
    var walletModel = WalletModel()

    private var deleteBulletinManager: BLTNItemManager?

    private var exportBulletinManager: BLTNItemManager?

    private var modifyWalletNameBulletinManager: BLTNItemManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "钱包管理"
        appModel = AppModel.current
        walletModel = appModel.currentWallet!
        walletAddressLabel.text = walletModel.address
        walletNameLabel.text = walletModel.name
        walletIconImageView.image = UIImage(data: walletModel.iconData)
    }

    func createDeleteWalletPageItem() -> PasswordPageItem {
        let passwordPageItem = PasswordPageItem.create(title: "删除钱包", actionButtonTitle: "确认删除")

        passwordPageItem.actionHandler = { [weak self] item in
            item.manager?.displayActivityIndicator()
            guard let self = self else {
                return
            }
            self.deleteWallet(password: passwordPageItem.passwordField.text!, item: item as! PasswordPageItem)
        }
        return passwordPageItem
    }

    func creatExportKeystorePageItem() -> PasswordPageItem {
        let passwordPageItem = PasswordPageItem.create(title: "导出Keystore", actionButtonTitle: "确认")
        passwordPageItem.actionHandler = { [weak self] item in
            item.manager?.displayActivityIndicator()
            guard let self = self else {
                return
            }
            self.exportKeystore(password: passwordPageItem.passwordField.text!, item: item as! PasswordPageItem)
        }
        return passwordPageItem
    }

    func creatModifyWalletNamePageItem() -> ModifyWalletNamePageItem {
        let modifyWalletNamePageItem = ModifyWalletNamePageItem.create()
        modifyWalletNamePageItem.actionHandler = { [weak self] item in
            item.manager?.displayActivityIndicator()
            guard let self = self else {
                return
            }
            self.modifyWalletName(walletName: modifyWalletNamePageItem.walletNameField.text!, item: item as! ModifyWalletNamePageItem)
        }
        return modifyWalletNamePageItem
    }

    @IBAction func didDeleteWallet(_ sender: UIButton) {
        deleteBulletinManager = BLTNItemManager(rootItem: createDeleteWalletPageItem())
        deleteBulletinManager?.showBulletin(above: self)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                modifyWalletNameBulletinManager = BLTNItemManager(rootItem: creatModifyWalletNamePageItem())
                modifyWalletNameBulletinManager?.showBulletin(above: self)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                exportBulletinManager = BLTNItemManager(rootItem: creatExportKeystorePageItem())
                exportBulletinManager?.showBulletin(above: self)
            }
        }
    }

    func modifyWalletName(walletName: String, item: ModifyWalletNamePageItem) {
        do {
            let realm = try! Realm()
            try realm.write {
                self.walletModel.name = walletName
            }
            self.walletNameLabel.text = walletName
            modifyWalletNameBulletinManager?.dismissBulletin()
        } catch let error {
            item.errorMessage = error.localizedDescription
            modifyWalletNameBulletinManager?.hideActivityIndicator()
        }
    }

    func exportKeystore(password: String, item: PasswordPageItem) {
        do {
            let wallet = AppModel.current.currentWallet!.wallet!
            let keystore = try WalletManager.default.exportKeystore(wallet: wallet, password: password)

            let exportController = ExportKeystoreController(nibName: "ExportKeystoreController", bundle: nil)
            exportController.keystoreString = keystore
            exportBulletinManager?.dismissBulletin()
            self.navigationController?.pushViewController(exportController, animated: true)
        } catch let error {
            item.errorMessage = error.localizedDescription
            exportBulletinManager?.hideActivityIndicator()
        }
    }

    func deleteWallet(password: String, item: PasswordPageItem) {
        let appItem = AppModel.current
        let walletItem = appItem.currentWallet!
        let wallet = walletItem.wallet!
        do {
            try WalletManager.default.deleteWallet(wallet: wallet, password: password)
            let realm = try! Realm()
            try realm.write {
                realm.delete(self.walletModel)
                appItem.currentWallet = appItem.wallets.first
            }
            Toast.showToast(text: "删除成功")
            deleteBulletinManager?.dismissBulletin()
            self.navigationController?.popViewController(animated: true)
        } catch let error {
            item.errorMessage = error.localizedDescription
            deleteBulletinManager?.hideActivityIndicator()
        }
    }
}
