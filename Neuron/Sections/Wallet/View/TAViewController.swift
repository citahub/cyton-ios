//
//  TAViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TAViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,AddAssetTableViewCellDelegate,TAViewControllerCellDelegate {
    
    let nameArray = ["地址","转账金额"]
    let plactholderArray = ["输入转账地址或扫码","余额xxx"]
    
    let tCtrl = TACustomViewController.init(nibName: "TACustomViewController", bundle: nil)

    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var tTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "转账"
        tTable.delegate = self
        tTable.dataSource = self
        tTable.isScrollEnabled = false
        tTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        tTable.register(UINib.init(nibName: "TAViewControllerCell", bundle: nil), forCellReuseIdentifier: "ID1")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 80
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! TAViewControllerCell
            cell.contentView.isUserInteractionEnabled = true
            cell.progress = 0.5
            cell.delegate = self
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! AddAssetTableViewCell
            cell.delegate = self
            cell.headLable.text = nameArray[indexPath.row]
            cell.placeHolderStr = plactholderArray[indexPath.row]
            cell.indexP = indexPath as NSIndexPath
            if indexPath.row == 0  {
                cell.selectRow = 1
                
            }else{
                cell.selectRow = 3
            }
            
            return cell
        }
    }
    
    //cell代理
    //textfield内容
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        
    }
    //拉动进度条返回的进度 0~1之间
    func didCallbackCurrentProgress(progress: Float) {
        
    }
    
    //界面本身的点击事件
    //点击qrcode
    func didClickQRCodeBtn() {
        
    }
    //点击下一步
    @IBAction func didClickNextButton(_ sender: UIButton) {
        UIApplication.shared.keyWindow?.addSubview(tCtrl.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
