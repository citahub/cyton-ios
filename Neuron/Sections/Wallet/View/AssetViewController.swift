//
//  AssetViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AssetViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {


    @IBOutlet weak var aTable: UITableView!
    let viewModel = AssetViewModel()
    var dataArray:[TokenModel] = []
    var selectArr:List<TokenModel>?
    var selectAddressArray:[String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didGetDataForList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资产管理"
        aTable.delegate = self
        aTable.dataSource = self
        aTable.register(UINib.init(nibName: "AssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        didSetRightBtn()
    }
    func didGetDataForList() {
        selectAddressArray.removeAll()
        dataArray = viewModel.getAssetListFromJSON()
        selectArr = viewModel.getSelectAsset()
        for tokenItem in selectArr! {
            selectAddressArray.append(tokenItem.address)
        }
        aTable.reloadData()
    }
    
    //setup nav
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
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath) as! AssetTableViewCell
        
        let tokenModel = dataArray[indexPath.row]
        cell.iconUrlStr = tokenModel.iconUrl
        cell.titleLable.text = tokenModel.name
        cell.addressLable.text = tokenModel.address
        cell.subTitleLable.text = tokenModel.symbol
        if selectAddressArray.contains(tokenModel.address) {
            cell.isSelect = true
        }else{
            cell.isSelect = false
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tokenModel = dataArray[indexPath.row]
        if selectAddressArray.contains(tokenModel.address) {
            viewModel.deleteSelectedToken(tokenM: tokenModel)
            selectAddressArray = selectAddressArray.filter({ (item) -> Bool in
                return item == tokenModel.address
            })
            print(selectAddressArray)
        }else{
            viewModel.addSelectToken(tokenM: tokenModel)
        }
        didGetDataForList()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
