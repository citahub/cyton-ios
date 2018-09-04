//
//  ManageAssetViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class ManageAssetViewController: UITableViewController {
    let viewModel = AssetViewModel()
    var dataArray: [TokenModel] = []
    var selectArr: List<TokenModel>?
    var selectAddressArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资产管理"
//        tableView.register(AssetTableViewCell.self, forCellReuseIdentifier: "assetTableviewCell")
        didGetDataForList()
    }
    
    func didGetDataForList() {
        selectAddressArray.removeAll()
        dataArray = viewModel.getAssetListFromJSON()
        selectArr = viewModel.getSelectAsset()
        for tokenItem in selectArr! {
            selectAddressArray.append(tokenItem.address)
        }
    }

    @IBAction func addAssetAction(_ sender: UIBarButtonItem) {
        let aCtrl = AddAssetController.init(nibName: "AddAssetController", bundle: nil)
        navigationController?.pushViewController(aCtrl, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetTableviewCell") as! AssetTableViewCell

//        let tokenModel = dataArray[indexPath.row]
//        cell.iconUrlStr = tokenModel.iconUrl
//        cell.symbolLabel.text = tokenModel.name
//        cell.addressLabel.text = tokenModel.address
//        cell.nameLabel.text = tokenModel.symbol
//        if selectAddressArray.contains(tokenModel.address) {
//            cell.isSelect = true
//        } else {
//            cell.isSelect = false
//        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tokenModel = dataArray[indexPath.row]
        print(tokenModel.address)
        if selectAddressArray.contains(tokenModel.address) {
            viewModel.deleteSelectedToken(tokenM: tokenModel)
            selectAddressArray = selectAddressArray.filter({ (item) -> Bool in
                return item == tokenModel.address
            })
        } else {
            viewModel.addSelectToken(tokenM: tokenModel)
        }
        didGetDataForList()
        tableView.reloadData()
    }
}
