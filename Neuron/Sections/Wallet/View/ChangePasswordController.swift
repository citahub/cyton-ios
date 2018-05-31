//
//  ChangePasswordController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ChangePasswordController: BaseViewController,UITableViewDelegate,UITableViewDataSource,AddAssetTableViewCellDelegate {
    
    
    let titleArray = ["","输入密码","输入新密码","再次输入新密码"]
    let placeholderArray = ["","输入密码","填写新密码","再次填写新密码"]
    
    @IBOutlet weak var changePwBtn: UIButton!
    @IBOutlet weak var cTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改密码"
        view.backgroundColor = ColorFromString(hex: "#f5f5f9")
        cTable.delegate = self
        cTable.dataSource = self
        cTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID1")
        
    }
    //修改密码按钮action
    @IBAction func changePasswordBtn(_ sender: UIButton) {
        
    }
    
    
    //table代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
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
            cell?.detailTextLabel?.text = "钱包名称a"
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! AddAssetTableViewCell
            cell.delegate = self
            cell.indexP = indexPath as NSIndexPath
            cell.headLable.text = titleArray[indexPath.row]
            cell.placeHolderStr = placeholderArray[indexPath.row]
            
            return cell
        }
    }
    
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
