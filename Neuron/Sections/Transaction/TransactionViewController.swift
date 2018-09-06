//
//  TransactionViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var paymentButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易列表"
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionTableviewCell

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
