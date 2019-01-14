//
//  NFTViewController.swift
//  Cyton
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
        title = "DApp.NFT.Title".localized()
        getListData()
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        getListData()
    }

    func getListData() {
        dataArray.removeAll()
        let appModel = AppModel.current
        let address = appModel.currentWallet!.address
        DispatchQueue.global().async {
            let result = try? NFTService().getErc721Data(with: address)
            DispatchQueue.main.async {
                if let nftModel = result {
                    self.dataArray = nftModel.assets ?? []
                    if self.dataArray.count == 0 {
                        self.showBlankOverlay()
                        self.errorOverlaycontroller.messageLabel.text = "DApp.NFT.EmptyData".localized()
                    } else {
                        self.removeOverlay()
                    }
                } else {
                    Toast.showToast(text: "Common.NetworkError".localized())
                    self.showNetworkFailOverlay()
                }
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
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
