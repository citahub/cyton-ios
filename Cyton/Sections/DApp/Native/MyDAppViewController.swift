//
//  CollectionViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/11/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class MyDAppViewController: UITableViewController, ErrorOverlayPresentable {
    @IBOutlet weak var dappIconImageView: UIImageView!
    @IBOutlet weak var dappNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var collections: [DAppModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DApp.MyDApp.Title".localized()
        getCollectionData()
    }

    func getCollectionData() {
        let realm = try! Realm()
        let result = realm.objects(DAppModel.self)
        if result.count == 0 {
            showBlankOverlay()
        } else {
            collections.append(contentsOf: result)
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionTableViewCell", for: indexPath) as! CollectionTableViewCell
        let model = collections[indexPath.row]
        cell.dappIconImageView.sd_setImage(with: URL(string: model.iconUrl ?? ""), placeholderImage: UIImage(named: "dapp_default"))
        cell.dappNameLabel.text = model.name
        cell.timeLabel.text = model.date
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = collections[indexPath.row]
        let browserViewController: BrowserViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
        browserViewController.requestUrlStr = model.entry
        self.navigationController?.pushViewController(browserViewController, animated: true)
    }
}
