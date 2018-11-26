//
//  NFTViewController.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

/// ERC-721 List
class NFTViewController: UITableViewController, ErrorOverlayPresentable {
    var dataArray: [AssetsModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的藏品"
        getListData()
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        getListData()
    }

    func getListData() {
        dataArray.removeAll()
        let appModel = AppModel.current
        let address = appModel.currentWallet!.address
        let nftService = NFTService()
        nftService.getErc721Data(with: address) { (result) in
            switch result {
            case .success(let nftModel):
                self.dataArray = nftModel.assets ?? []
                if self.dataArray.count == 0 {
                    self.showBlankOverlay()
                } else {
                    self.removeOverlay()
                }
            case .error:
                Toast.showToast(text: "网络错误，请稍后再试.")
                self.showNetworkFailOverlay()
            }
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
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
}
