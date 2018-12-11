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
    var dataArray: [TokenModel] = []
    var selectArr: List<TokenModel>?
    var selectAddressArray: [String] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ERC20列表"
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
        cell.isSelected = selectAddressArray.contains(tokenModel.address)

        return cell
    }

    func selectAsset(_ assetTableViewCell: UITableViewCell, didSelectAsset switch: UISwitch) {
        let index = tableView.indexPath(for: assetTableViewCell)!
        let model = dataArray[index.row]
    }

}
