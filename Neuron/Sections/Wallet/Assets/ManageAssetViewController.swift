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
    @IBOutlet weak var rightBarButton: DesignableButton!
    var tokenArray: List<TokenModel>!
    var selectArray: List<TokenModel>!
    var realm: Realm!
    var edit: Bool!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        title = "Assets.AddAssets.ListSettings".localized()
        rightBarButton.setTitle("Assets.AssetSetting.Edit".localized(), for: .normal)
        rightBarButton.setTitle("Assets.AssetSetting.Complete".localized(), for: .selected)
        edit = false
        tokenList()
    }

    @IBAction func clickEditListButton(_ sender: DesignableButton) {
        if sender.isSelected {
            sender.isSelected = false
            sortSelectTokenArray()
        } else {
            sender.isSelected = true
        }
        tableView.setEditing(sender.isSelected, animated: true)
        edit = sender.isSelected
    }

    func sortSelectTokenArray() {
        let tempArray = List<TokenModel>()
        tempArray.append(objectsIn: selectArray)
        try! realm.write {
            selectArray.removeAll()
            tokenArray.forEach({ (model) in
                if let token = tempArray.first(where: { $0 == model }) {
                    selectArray.append(token)
                }
            })
        }
    }

    func tokenList() {
        let appModel = realm.objects(AppModel.self).first ?? AppModel()
        tokenArray = appModel.currentWallet?.tokenModelList
        selectArray = appModel.currentWallet?.selectedTokenList
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetTableviewCell") as! AssetTableViewCell
        cell.delegate = self
        let tokenModel = tokenArray[indexPath.row]
        cell.iconUrlStr = tokenModel.iconUrl
        cell.symbolLabel.text = tokenModel.name
        cell.addressLabel.text = tokenModel.address
        cell.nameLabel.text = tokenModel.symbol
        cell.selectionStyle = .none
        cell.isSelected = selectArray.contains(where: { $0 == tokenModel })
        return cell
    }

    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AssetTableViewCell
        cell.setEditing(true, animated: true)
    }

    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let cell = tableView.cellForRow(at: indexPath!) as! AssetTableViewCell
        cell.setEditing(false, animated: true)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            swap(&tokenArray[sourceIndexPath.row], &tokenArray[destinationIndexPath.row])
        }
    }

    func selectAsset(_ assetTableViewCell: UITableViewCell, didSelectAsset switchButton: UISwitch) {
        let index = tableView.indexPath(for: assetTableViewCell)!
        let tokenModel = tokenArray[index.row]
        try! realm.write {
            if switchButton.isOn {
                if !selectArray.contains(where: { $0 == tokenModel }) {
                    selectArray.append(tokenModel)
                }
            } else {
                if selectArray.contains(where: { $0 == tokenModel }) {
                    selectArray.remove(at: selectArray.index(of: tokenModel)!)
                }
            }
        }
    }
}
