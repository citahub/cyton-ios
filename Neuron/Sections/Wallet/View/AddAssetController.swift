//
//  AddAssetController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class AddAssetController: BaseViewController,UITableViewDelegate,UITableViewDataSource,AddAssetTableViewCellDelegate,NEPickerViewDelegate {
    

    
    let titleArray = ["区块链","合约地址","代币名称","代币缩写","小数位数"]
    let placeholderArray = ["","合约地址","代币名称","代币缩写","小数位数"]
    
    let nView =  NEPickerView.init()
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var aTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "添加资产"
        view.backgroundColor = ColorFromString(hex: "f5f5f5")
        aTable.delegate = self
        aTable.dataSource = self
        aTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        aTable.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenW, height: CGFloat.leastNormalMagnitude))

    }
    
    @IBAction func didClickAddButton(_ sender: UIButton) {
        
    }
    //tableview代理
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! AddAssetTableViewCell
        cell.delegate = self
        cell.indexP = indexPath as NSIndexPath
        cell.headLable.text = titleArray[indexPath.row]
        cell.placeHolderStr = placeholderArray[indexPath.row]
        cell.selectRow = indexPath.row
        if indexPath.row == 0 {
            cell.rightTextField.text = "以太坊"
        }
        return cell
    }

    
    //cell的代理 弹出pickerview
    func didClickSelectCoinBtn() {
        nView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        nView.delegate = self
        nView.dataArray = [["name":"以太坊","id":"1"],["name":"比特币","id":"2"]]
        UIApplication.shared.keyWindow?.addSubview(nView)
    }
    
    func callBackDictionnary(dict: [String : String]) {
        print(dict["name"]!)
    }

    
    func didClickQRCodeBtn() {
        
    }
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        print(text)
        print(index.row)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
