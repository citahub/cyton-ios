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

    //修改密码按钮action
    @IBAction func changePasswordBtn(_ sender: UIButton) {
        if walletModel.MD5screatPassword != CryptTools.changeMD5(password: oldPassword) {NeuLoad.showToast(text: "旧密码错误");return}
        if newPassword != confirmPassword {NeuLoad.showToast(text: "两次新密码输入不一致");return}
        if !isThePasswordMeetCondition(password: newPassword) {return}
        if walletModel.MD5screatPassword == CryptTools.changeMD5(password: newPassword) {
            NeuLoad.showToast(text: "新密码与旧密码一致，请重新输入")
            return
        }
        let privateKey = CryptTools.Decode_AES_ECB(strToDecode: walletModel.encryptPrivateKey, key: oldPassword)
        let newEncryptPrivateKey = CryptTools.Endcode_AES_ECB(strToEncode: privateKey, key: newPassword)
        NeuLoad.showHUD(text: "修改密码中...")
        try! WalletRealmTool.realm.write {
            walletModel.encryptPrivateKey = newEncryptPrivateKey
            walletModel.MD5screatPassword = CryptTools.changeMD5(password: newPassword)
        }
        let address = walletModel.address
        let oldP = oldPassword
        let newP = newPassword
        DispatchQueue.global(qos: .userInteractive).async {
            WalletCryptoService.updateEncryptPrivateKey(oldPassword: oldP, newPassword: newP, walletAddress: address)
            DispatchQueue.main.async {
                NeuLoad.hidHUD()
                NeuLoad.showToast(text: "密码修改成功，请牢记！")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    //table代理
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
