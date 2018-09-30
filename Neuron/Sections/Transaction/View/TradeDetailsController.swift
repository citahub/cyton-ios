//
//  TradeDetailsController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TradeDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tModel = TransactionModel() {
        didSet {
            if tModel.transactionType == "ETH" {
                titleArr = ["区块链网络", "接受方", "发送方", "手续费", "GasPrice", "交易流水号", "所在区块", "入块时间"]
                subBtnArr = [tModel.chainName,
                             tModel.to,
                             tModel.from,
                             tModel.totleGas + "eth",
                             tModel.gasPrice + "Gwei",
                             tModel.hashString,
                             tModel.blockNumber,
                             tModel.formatTime]
            } else if tModel.transactionType == "Nervos" {
                titleArr = ["区块链网络", "接受方", "发送方", "手续费", "交易流水号", "所在区块", "入块时间"]
                subBtnArr = [tModel.chainName,
                             tModel.to,
                             tModel.from,
                             tModel.gasUsed + tModel.symbol,
                             tModel.hashString,
                             tModel.blockNumber,
                             tModel.formatTime]
            }
        }
    }

    private var titleArr = [""]
    private var subBtnArr = [""]
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var tTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易详情"
        didSetUIDetail()
        tTable.delegate = self
        tTable.dataSource = self
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet
        iconImage.image = UIImage(data: (walletModel?.iconData)!)
        tTable.register(UINib.init(nibName: "TradeTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        amountLabel.text = tModel.value
        addressLabel.text = walletModel?.address
        nameLabel.text = walletModel?.name
        tTable.reloadData()
    }
    func didSetUIDetail() {
        headView.layer.shadowColor = ColorFromString(hex: "#ededed").cgColor
        headView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headView.layer.shadowOpacity = 0.3
        headView.layer.shadowRadius = 2.75
        headView.layer.cornerRadius = 5
        headView.layer.borderWidth = 1
        headView.layer.borderColor = ColorFromString(hex: "#ededed").cgColor
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! TradeTableViewCell
        cell.ethOrNervos = tModel.transactionType
        cell.selectIndex = indexPath as NSIndexPath
        cell.titleStr = titleArr[indexPath.row]
        cell.subTitleStr = subBtnArr[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
