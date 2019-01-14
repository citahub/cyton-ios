//
//  WalletDetailController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BLTNBoard
import RealmSwift

class WalletDetailController: UITableViewController {
    @IBOutlet private weak var walletNameLabel: UILabel!
    @IBOutlet private weak var walletAddressLabel: UILabel!
    @IBOutlet private var walletIconImageView: UIImageView!
    @IBOutlet private weak var iconTitleLabel: UILabel!
    @IBOutlet private weak var nameTItleLabel: UILabel!
    @IBOutlet private weak var addressTitleLabel: UILabel!
    @IBOutlet private weak var changePwTitleLabel: UILabel!
    @IBOutlet private weak var exprotKeystoreTItleLabel: UILabel!
    @IBOutlet private weak var deleteWalletButton: UIButton!

    var appModel = AppModel()
    var walletModel = WalletModel()

    private var deleteBulletinManager: BLTNItemManager?
    private var exportBulletinManager: BLTNItemManager?
    private var modifyWalletNameBulletinManager: BLTNItemManager?
    private var walletObserve: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Details.title".localized()
        appModel = AppModel.current
        walletModel = appModel.currentWallet!
        walletAddressLabel.text = walletModel.address
        walletNameLabel.text = walletModel.name
        walletIconImageView.image = walletModel.icon.image

        iconTitleLabel.text = "Wallet.Details.icon".localized()
        nameTItleLabel.text = "Wallet.Details.name".localized()
        addressTitleLabel.text = "Wallet.Details.address".localized()
        changePwTitleLabel.text = "Wallet.Details.changePassword".localized()
        exprotKeystoreTItleLabel.text = "Wallet.Details.exportKeystore".localized()
        deleteWalletButton.setTitle("Wallet.Details.delete".localized(), for: .normal)

        walletObserve = walletModel.observe { [weak self](change) in
            switch change {
            case .change(let propertyChanges):
                if propertyChanges.contains(where: { $0.name == "iconName" }) {
                    self?.walletIconImageView.image = self?.walletModel.icon.image
                }
            default:
                break
            }
        }
    }

    deinit {
        walletObserve?.invalidate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: WalletIconPickerViewController.self) {
            let controller = segue.destination as! WalletIconPickerViewController
            controller.wallet = walletModel
        }
    }

    func createDeleteWalletPageItem() -> PasswordPageItem {
        let passwordPageItem = PasswordPageItem.create(title: "Wallet.Details.deleteWallet".localized(), actionButtonTitle: "Wallet.Details.confirmDeleteWallet".localized())

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
        let passwordPageItem = PasswordPageItem.create(title: "Wallet.Details.importKeystore".localized(), actionButtonTitle: "Common.confirm".localized())
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
            Toast.showToast(text: "Wallet.Details.deleteWalletSuccess".localized())
            deleteBulletinManager?.dismissBulletin()
            self.navigationController?.popViewController(animated: true)
        } catch let error {
            item.errorMessage = error.localizedDescription
            deleteBulletinManager?.hideActivityIndicator()
        }
    }
}
