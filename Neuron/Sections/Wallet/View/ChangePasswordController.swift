//
//  ChangePasswordController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ChangePasswordController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddAssetTableViewCellDelegate {
    let titleArray = ["", "输入旧密码", "输入新密码", "再次输入新密码"]
    let placeholderArray = ["", "输入旧密码", "填写新密码", "再次填写新密码"]

    var walletModel = WalletModel()

    var oldPassword: String = ""
    var newPassword: String = ""
    var confirmPassword: String = ""

    @IBOutlet weak var changePwBtn: UIButton!
    @IBOutlet weak var cTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改密码"
        view.backgroundColor = ColorFromString(hex: "#f5f5f9")
        cTable.delegate = self
        cTable.dataSource = self
        cTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID1")
        didGetData()
    }

    func didGetData() {
        walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        cTable.reloadData()
    }

    @IBAction func changePasswordBtn(_ sender: UIButton) {
        if newPassword != confirmPassword {
            Toast.showToast(text: "两次新密码输入不一致")
            return
        }
        if !PasswordValidator.isValid(password: newPassword) {
            return
        }
        Toast.showHUD(text: "修改密码中...")
        let address = walletModel.address
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            do {
                try WalletCryptoService.updatePassword(address: address, password: self.oldPassword, newPassword: self.newPassword)
            } catch {
                DispatchQueue.main.async {
                    // TODO: check if hideHUD prevents next showToast from showing up
                    Toast.hideHUD()
                    Toast.showToast(text: "密码错误")
                }
                return
            }
            DispatchQueue.main.async {
                Toast.hideHUD()
                Toast.showToast(text: "密码修改成功，请牢记！")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "ID")
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ID")
                cell?.textLabel?.textColor = ColorFromString(hex: "#333333")
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell?.detailTextLabel?.textColor = ColorFromString(hex: "#333333")
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            }

            cell?.textLabel?.text = "钱包名称"
            cell?.detailTextLabel?.text = walletModel.name
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! AddAssetTableViewCell
            cell.delegate = self
            cell.indexP = indexPath as NSIndexPath
            cell.isSecretText = true
            cell.headLabel.text = titleArray[indexPath.row]
            cell.placeHolderStr = placeholderArray[indexPath.row]
            return cell
        }
    }

    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        switch index.row {
        case 1:
            oldPassword = text
        case 2:
            newPassword = text
        case 3:
            confirmPassword = text
        default: break
        }
        if !oldPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty {
            changePwBtn.isEnabled = true
            changePwBtn.setTitleColor(.white, for: .normal)
            changePwBtn.backgroundColor = AppColor.themeColor
        } else {
            changePwBtn.isEnabled = false
            changePwBtn.setTitleColor(ColorFromString(hex: "#999999"), for: .normal)
            changePwBtn.backgroundColor = ColorFromString(hex: "#F2F2F2")
        }
    }
}
