//
//  SubController4.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SubController4: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    let titleArray = ["源代码","服务及隐私条款","联系我们"]
//    let imageArray = ["aboutus","contactus"]
    

    @IBOutlet weak var sTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        sTable.delegate = self
        sTable.dataSource = self
        sTable.tableFooterView = UIView.init()
        sTable.register(UINib.init(nibName: "SubController4TableViewCell", bundle: nil), forCellReuseIdentifier: "ID1")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return titleArray.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1",for:indexPath) as! SubController4TableViewCell
            cell.selectionStyle = .none
            return cell
        }else{
            let ID = "ID"
            var cell = tableView.dequeueReusableCell(withIdentifier: ID)
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: ID)
                cell?.textLabel?.textColor = ColorFromString(hex: "#333333")
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            }
            cell?.textLabel?.text = titleArray[indexPath.row]
            cell?.accessoryType = .disclosureIndicator
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }else{
            return 50
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
