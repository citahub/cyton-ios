//
//  AssetViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class AssetViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {


    @IBOutlet weak var aTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资产管理"
        aTable.delegate = self
        aTable.dataSource = self
        aTable.register(UINib.init(nibName: "AssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        didSetRightBtn()
        
    }
    //设置导航栏按钮
    func didSetRightBtn()  {
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        rightBtn.setImage(UIImage.init(named: "添加"), for: .normal)
        rightBtn.addTarget(self, action: #selector(didAddAsset), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
    }
    
    //添加资产
    @objc func didAddAsset(){
        let aCtrl = AddAssetController.init(nibName: "AddAssetController", bundle: nil)
        navigationController?.pushViewController(aCtrl, animated: true)
    }
    
    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath) as! AssetTableViewCell
        
        

        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
