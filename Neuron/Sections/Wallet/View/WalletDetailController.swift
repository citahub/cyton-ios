//
//  WalletDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SCLAlertView

class WalletDetailController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    

    @IBOutlet weak var deleteWalletBtn: UIButton!
    @IBOutlet weak var wTable: UITableView!
    
    var appModel = AppModel()
    var walletModel = WalletModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        title = "钱包管理"
        appModel = WalletRealmTool.getCurrentAppmodel()
        walletModel = appModel.currentWallet!
        view.backgroundColor = ColorFromString(hex: "#efeff4")
        wTable.dataSource = self
        wTable.delegate = self
        wTable.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenW, height: CGFloat.leastNormalMagnitude))
        wTable.register(UINib.init(nibName: "DetailIconCell", bundle: nil), forCellReuseIdentifier: "ID1")
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
            }else{
                self.deleteWallet(password: txt.text!)
            }
        }
        alert.addButton("取消") {
            
        }
        alert.showEdit("删除钱包", subTitle: "请确保您已经做好钱包备份",colorStyle: 0x2e4af2,
                       colorTextButton: 0xFFFFFF)
    }
    
    func deleteWallet(password:String) {
        let address = walletModel.address
        
        try! WalletRealmTool.realm.write {
            if appModel.wallets.count == 1{
                WalletRealmTool.realm.deleteAll()
                NotificationCenter.default.post(name: .changeTabbr, object: self, userInfo: nil)
            }else{
                appModel.currentWallet = appModel.wallets[0]
                WalletRealmTool.realm.delete(walletModel)
            }
        }
        WalletCryptService.didDelegateWallet(password: password, walletAddress: address)
        NeuLoad.showToast(text: "删除成功")
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    //tableview代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! DetailIconCell
                cell.iconImage.image = UIImage.init(data: walletModel.iconData)
                return cell
            }else{
                let ID2 = "ID2"
                var cell = tableView.dequeueReusableCell(withIdentifier: ID2)
                if cell == nil {
                    cell = UITableViewCell.init(style: .value1, reuseIdentifier: ID2)
                }
                cell?.textLabel?.textColor = ColorFromString(hex: "#333333")
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell?.detailTextLabel?.textColor = ColorFromString(hex: "#999999")
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
                switch indexPath.row {
                case 1:
                    cell?.textLabel?.text = "钱包名称"
                    cell?.accessoryType = .disclosureIndicator
                    cell?.detailTextLabel?.text = walletModel.name
                    break
                case 2:
                    cell?.textLabel?.text = "钱包地址"
                    cell?.detailTextLabel?.text = walletModel.address
                    break
                default:
                    break
                }
                
                return cell!
            }
        }else{
            let ID = "ID"
            var cell = tableView.dequeueReusableCell(withIdentifier: ID)
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: ID)
            }
            cell?.textLabel?.textColor = ColorFromString(hex: "#333333")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.accessoryType = .disclosureIndicator
            
            switch indexPath.row {
            case 0 :
                cell?.textLabel?.text = "修改密码"
                break
            case 1:
                cell?.textLabel?.text = "导出ketStore"
                break
            default:
                break
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 80
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                didChangeWalletNmae()
            }
        }else if(indexPath.section == 1){
            if indexPath.row == 0 {
                let pCtrl = ChangePasswordController.init(nibName: "ChangePasswordController", bundle: nil)
                navigationController?.pushViewController(pCtrl, animated: true)
            }
            if indexPath.row == 1{
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
                    }else{
                        let eCtrl = ExportKeyStoreController.init(nibName: "ExportKeyStoreController", bundle: nil)
                        eCtrl.password = txt.text!
                        self.navigationController?.pushViewController(eCtrl, animated: true)
                    }
                }
                alert.addButton("取消") {
                    
                }
                alert.showEdit("导出keystore", subTitle: "",colorStyle: 0x2e4af2,
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
            if !WalletTools.checkWalletName(name: txt.text!) && !txt.text!.isEmpty {NeuLoad.showToast(text: "该钱包名称已存在");return}else{
                if txt.text!.isEmpty {
                    NeuLoad.showToast(text: "钱包名字不能为空")
                }else{
                    try! WalletRealmTool.realm.write {
                        self.walletModel.name = txt.text!
                        self.wTable.reloadData()
                    }
                }
            }
        }
        alert.addButton("取消") {
            
        }
        alert.showEdit("修改钱包名称", subTitle: "",colorStyle: 0x2e4af2,
                       colorTextButton: 0xFFFFFF)
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
