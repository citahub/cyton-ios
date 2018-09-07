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
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.ly_emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "暂无藏品", detailStr: "")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ERC721TableviewCell") as! ERC721TableViewCell
        return cell
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
