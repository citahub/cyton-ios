//
//  WalletDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class WalletDetailController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    

    @IBOutlet weak var deleteWalletBtn: UIButton!
    @IBOutlet weak var wTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        title = "钱包管理"
        view.backgroundColor = ColorFromString(hex: "#efeff4")
        wTable.dataSource = self
        wTable.delegate = self
        wTable.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenW, height: CGFloat.leastNormalMagnitude))
        wTable.register(UINib.init(nibName: "DetailIconCell", bundle: nil), forCellReuseIdentifier: "ID1")
    }
    
    @IBAction func didDeletWallet(_ sender: UIButton) {
        print("删除钱包")
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
                    cell?.detailTextLabel?.text = "我是钱包"
                    break
                case 2:
                    cell?.textLabel?.text = "钱包地址"
                    cell?.detailTextLabel?.text = "我是钱包地址"
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
        if indexPath.section == 1 && indexPath.row == 0 {
            let pCtrl = ChangePasswordController.init(nibName: "ChangePasswordController", bundle: nil)
            navigationController?.pushViewController(pCtrl, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
