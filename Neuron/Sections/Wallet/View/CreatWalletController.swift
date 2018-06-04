//
//  CreatWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class CreatWalletController: BaseViewController,UITableViewDataSource,UITableViewDelegate,AddAssetTableViewCellDelegate {

    

    let titleArray = ["钱包名称","设定密码","重复密码"]
    let placeholderArray = ["请输入钱包名称","请输入密码","请确认密码"]
    
    @IBOutlet weak var cTable: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "创建钱包"
        view.backgroundColor = ColorFromString(hex: "#f5f5f9")
        cTable.delegate = self
        cTable.dataSource = self
        cTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID1")

    }
    
    
    //table代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! AddAssetTableViewCell
        cell.delegate = self
        cell.indexP = indexPath as NSIndexPath
        cell.headLable.text = titleArray[indexPath.row]
        cell.placeHolderStr = placeholderArray[indexPath.row]
        
        
        return cell
    }

    //cell代理
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        
    }
    
    @IBAction func didClickNextButton(_ sender: UIButton) {
        let gCtrl = GenerateMnemonicController.init(nibName: "GenerateMnemonicController", bundle: nil)
        navigationController?.pushViewController(gCtrl, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
