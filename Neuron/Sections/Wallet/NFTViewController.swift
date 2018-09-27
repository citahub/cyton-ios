//
//  NFTViewController.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import LYEmptyView

/// ERC-721 List
class NFTViewController: UITableViewController {
    var dataArray: [AssetsModel] = []
    private let testAddress = "0xac30bce77cf849d869aa37e39b983fa50767a2dd"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.ly_emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "暂无藏品", detailStr: "")
        getListData()
        addNotify()
    }

    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .beginRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .switchWallet, object: nil)
    }

    @objc
    func refreshData() {
        getListData()
    }

    func getListData() {
        dataArray.removeAll()
        let appModel = WalletRealmTool.getCurrentAppmodel()
        let address = appModel.currentWallet!.address
        let nftService = NFTService()
        nftService.getErc721Data(with: address) { (result) in
            switch result {
            case .Success(let nftModel):
                self.dataArray = nftModel.assets ?? []
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ERC721TableviewCell") as! ERC721TableViewCell

        let model = dataArray[indexPath.row]
        cell.ERC721Image.sd_setImage(with: URL(string: model.image_thumbnail_url ?? ""), placeholderImage: UIImage(named: "eth_logo"))
        cell.name.text = model.name
        cell.number.text = "ID:" + model.token_id
        cell.network.text = model.asset_contract.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        let nftDetailViewController = UIStoryboard(name: "NFTDetail", bundle: nil).instantiateViewController(withIdentifier: "nftDetailViewController") as! NFTDetailViewController
        nftDetailViewController.assetsModel = model
        navigationController?.pushViewController(nftDetailViewController, animated: true)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            offset += scrollView.adjustedContentInset.top
        } else {
            offset += scrollView.contentInset.top
        }

        tableView.isScrollEnabled = offset > 0
    }
}
