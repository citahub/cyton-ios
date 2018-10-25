//
//  TransactionViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import LYEmptyView
import PullToRefresh

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var transactionTableView: UITableView!
    var service: TransactionHistoryService?
    var dataArray: [TransactionModel] = []
    var tokenType: TokenType = .erc20Token
    var tokenModel: TokenModel! {
        didSet {
            guard tokenModel != nil else { return }
            service = TransactionHistoryService.service(with: tokenModel)
            loadData()
        }
    }
    let refresher = PullToRefresh()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易列表"
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        transactionTableView.ly_emptyView = LYEmptyView.empty(withImageStr: "emptyData", titleStr: "您还没有交易数据", detailStr: "")
        transactionTableView.addPullToRefresh(refresher) {
            self.loadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestPayment" {
            let requestPaymentViewController = segue.destination as! RequestPaymentViewController
            let appModel = WalletRealmTool.getCurrentAppModel()
            requestPaymentViewController.appModel = appModel
        }
        if segue.identifier == "payment" {
            let paymentViewController = segue.destination as! PaymentViewController
            paymentViewController.tokenType = tokenType
            paymentViewController.tokenModel = tokenModel
        }
    }

    private func loadData() {
        Toast.showHUD()
        service?.reloadData { (_) in
            Toast.hideHUD()
            self.dataArray = self.service?.transactions ?? []
            self.transactionTableView.reloadData()
            self.transactionTableView.endRefreshing(at: .top)
        }
    }

    private func loadMoreData() {
        service?.loadMoreDate(completion: { [weak self](insertions, _) in
            var indexPaths = [IndexPath]()
            for index in insertions {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
            self?.transactionTableView.insertRows(at: indexPaths, with: .none)
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionTableviewCell
        let transModel = dataArray[indexPath.row]
        cell.dateLabel.text = transModel.formatTime
        cell.networkLabel.text = transModel.chainName
        cell.statusImageView.image = UIImage(named: "transaction_success")
        let walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        if transModel.to.lowercased() == walletAddress.lowercased() {
            cell.addressLabel.text = transModel.from
            cell.exchangeLabel.text = "+\(transModel.value)"
        } else {
            cell.addressLabel.text = transModel.to
            cell.exchangeLabel.text = "-\(transModel.value)"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > dataArray.count - 4 {
            loadMoreData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transModel = dataArray[indexPath.row]
        let tCtrl = TradeDetailsController(nibName: "TradeDetailsController", bundle: nil)
        tCtrl.tModel = transModel
        navigationController?.pushViewController(tCtrl, animated: true)
    }

    deinit {
        transactionTableView.removeAllPullToRefresh()
    }
}

enum TokenType {
    case ethereumToken
    case nervosToken
    case erc20Token
}
