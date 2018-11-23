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
        didGetDataForList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ERC20列表"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAssetController" {
            let controller = segue.destination as! AddAssetController
            controller.tokenArray = dataArray
        }
    }

    func didGetDataForList() {
        selectAddressArray.removeAll()
        dataArray = getAssetListFromJSON()
        selectArr = getSelectAsset()
        for tokenItem in selectArr! {
            selectAddressArray.append(tokenItem.address)
        }
        tableView.reloadData()
    }

    func getAssetListFromJSON() -> [TokenModel] {
        var tokenArray: [TokenModel] = []

        let appModel = WalletRealmTool.getCurrentAppModel()
        let realm = try! Realm()
        for tModel in appModel.extraTokenList {
            try? realm.write {
                realm.add(tModel, update: true)
            }
            tokenArray.append(tModel)
        }

        let path = Bundle.main.path(forResource: "tokens-eth", ofType: "json")!
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return [] }
        guard let tokens = try? JSONDecoder().decode([TokenModel].self, from: jsonData) else { return [] }

        for token in tokens {
            token.iconUrl = token.logo?.src ?? ""
            tokenArray.append(token)
        }
        return tokenArray
    }

    func getSelectAsset() -> List<TokenModel>? {
        let appModel = WalletRealmTool.getCurrentAppModel()
        return appModel.currentWallet?.selectTokenList
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
        selectedAsset(model: model)
    }

    func selectedAsset(model: TokenModel) {
        if selectAddressArray.contains(model.address) {
            deleteSelectedToken(tokenM: model)
            selectAddressArray = selectAddressArray.filter({ (item) -> Bool in
                return item == model.address
            })
        } else {
            addSelectToken(tokenM: model)
        }
        didGetDataForList()
    }

    func deleteSelectedToken(tokenM: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let filterResult = appModel.currentWallet?.selectTokenList.filter("address = %@", tokenM.address)
        let realm = try! Realm()
        try? realm.write {
            realm.add(tokenM, update: true)
            filterResult?.forEach({ (tm) in
                if let index = appModel.currentWallet?.selectTokenList.index(of: tm) {
                    appModel.currentWallet?.selectTokenList.remove(at: index)
                }
            })
        }
    }

    func addSelectToken(tokenM: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let realm = try! Realm()
        try? realm.write {
            realm.add(tokenM, update: true)
            appModel.currentWallet?.selectTokenList.append(tokenM)
        }
    }
}
