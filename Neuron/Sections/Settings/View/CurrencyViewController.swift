//
//  CurrencyViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/24.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class CurrencyViewController: UITableViewController {

    var dataArray = [LocalCurrency]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "本地货币"
        getCurrencyList()
    }

    func getCurrencyList() {
        let localCurrencyService = LocalCurrencyService()
        dataArray = localCurrencyService.getLocalCurrencyList()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyTableViewCell
        let model = dataArray[indexPath.row]
        cell.symbolLabel.text = model.short
        if LocalCurrencyService().getLocalCurrencySelect().short == model.short {
            cell.selectImageView.isHidden = false
        } else {
            cell.selectImageView.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataArray[indexPath.row]
        LocalCurrencyService().saveLocalCurrency(model.short)
        NotificationCenter.default.post(name: .changeLocalCurrency, object: self, userInfo: nil)
        tableView.reloadData()
    }
}
