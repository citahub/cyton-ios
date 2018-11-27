//
//  TradeDetailsController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import Web3swift

class TradeDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var transaction: TransactionDetails! {
        didSet {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let dateText = dateformatter.string(from: transaction.date)

            if let ethereum = transaction as? EthereumTransactionDetails {
                transactionType = "ETH"
                let gasUsed = String(Double.fromAmount(ethereum.gasUsed * ethereum.gasPrice, decimals: ethereum.token.decimals))
                let gasPrice = Web3.Utils.formatToEthereumUnits(ethereum.gasPrice, toUnits: .Gwei, decimals: 8)!
                titleArr = ["区块链网络", "接受方", "发送方", "手续费", "GasPrice", "交易流水号", "所在区块", "入块时间"]
                subBtnArr = [
                    "Ethereum Mainnet",
                    ethereum.to,
                    ethereum.from,
                    gasUsed + "eth",
                    gasPrice + "Gwei",
                    ethereum.hash,
                    String(ethereum.blockNumber),
                    dateText
                ]
            } else if let appChain = transaction as? AppChainTransactionDetails {
                transactionType = "AppChain"
                let gasUsed = String(Double.fromAmount(appChain.gasUsed, decimals: appChain.token.decimals))
                titleArr = ["区块链网络", "接受方", "发送方", "手续费", "交易流水号", "所在区块", "入块时间"]
                subBtnArr = [
                    appChain.chainName,
                    appChain.to,
                    appChain.from,
                    gasUsed + "NATT",
                    appChain.hash,
                    String(appChain.blockNumber),
                    dateText
                ]
            }
        }
    }

    private var titleArr = [""]
    private var subBtnArr = [""]
    private var transactionType = ""
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
        let walletModel = AppModel.current.currentWallet
        iconImage.image = UIImage(data: (walletModel?.iconData)!)
        tTable.register(UINib.init(nibName: "TradeTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        amountLabel.text = Web3.Utils.formatToEthereumUnits(transaction.value, toUnits: .eth, decimals: 8)!
        addressLabel.text = walletModel?.address
        nameLabel.text = walletModel?.name
        tTable.reloadData()
    }

    func didSetUIDetail() {
        headView.layer.shadowColor = UIColor(hex: "#ededed").cgColor
        headView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headView.layer.shadowOpacity = 0.3
        headView.layer.shadowRadius = 2.75
        headView.layer.cornerRadius = 5
        headView.layer.borderWidth = 1
        headView.layer.borderColor = UIColor(hex: "#ededed").cgColor
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! TradeTableViewCell
        cell.ethOrNervos = transactionType
        cell.selectIndex = indexPath as NSIndexPath
        cell.titleStr = titleArr[indexPath.row]
        cell.subTitleStr = subBtnArr[indexPath.row]
        return cell
    }
}
