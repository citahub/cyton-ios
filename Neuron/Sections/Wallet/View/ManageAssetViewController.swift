//
//  ManageAssetViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class ManageAssetViewController: UITableViewController, AssetTableViewCellDelegate {
    let viewModel = AssetViewModel()
    var dataArray: [TokenModel] = []
    var selectArr: List<TokenModel>?
    var selectAddressArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资产管理"
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
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetTableviewCell") as! AssetTableViewCell
        cell.delegate = self
        let tokenModel = dataArray[indexPath.row]
        cell.iconUrlStr = tokenModel.iconUrl
        cell.symbolLabel.text = tokenModel.name
        cell.addressLabel.text = tokenModel.address
        cell.nameLabel.text = tokenModel.symbol
        cell.selectionStyle = .none
        if selectAddressArray.contains(tokenModel.address) {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }

        return cell
    }

    func selectAsset(_ assetTableViewCell: UITableViewCell, didSelectAsset switch: UISwitch) {
        let index = tableView.indexPath(for: assetTableViewCell)!
        let model = dataArray[index.row]
        selectedAsset(model: model)
    }

    func selectedAsset(model: TokenModel) {
        if selectAddressArray.contains(model.address) {
            viewModel.deleteSelectedToken(tokenM: model)
            selectAddressArray = selectAddressArray.filter({ (item) -> Bool in
                return item == model.address
            })
        } else {
            viewModel.addSelectToken(tokenM: model)
        }
        didGetDataForList()
    }
}
