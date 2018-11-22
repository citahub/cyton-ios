//
//  CollectionViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/11/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class CollectionViewController: UITableViewController {
    @IBOutlet weak var dappIconImageView: UIImageView!
    @IBOutlet weak var dappNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionTableViewCell", for: indexPath)


        return cell
    }
}
