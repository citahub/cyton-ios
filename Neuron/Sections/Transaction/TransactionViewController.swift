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
    let service = TransactionService()
    var dataArray: [TransactionModel] = []
    var tokenType: TokenType = .erc20Token
    var tokenModel = TokenModel()
    let refresher = PullToRefresh()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易列表"
        loadData()
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
        switch tokenType {
        case .ethereumToken:
            didGetEthTranscationData()
        case .nervosToken:
            didGetNervosTranscationData()
        case .erc20Token:
            transactionTableView.reloadData()
        }
    }

    func didGetEthTranscationData() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet
        service.didGetETHTransaction(walletAddress: (walletModel?.address)!) { (result) in
            switch result {
            case .success(let ethArray):
                self.dataArray = ethArray
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
            self.transactionTableView.endRefreshing(at: .top)
        }
    }

    func didGetNervosTranscationData() {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet
        service.didGetNervosTransaction(walletAddress: (walletModel?.address)!) { (result) in
            switch result {
            case .success(let nervosArray):
                self.dataArray = nervosArray
                self.transactionTableView.reloadData()
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
            self.transactionTableView.endRefreshing(at: .top)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionTableviewCell
        let transModel = dataArray[indexPath.row]
        cell.dateLabel.text = transModel.formatTime
        cell.exchangeLabel.text = transModel.value
        cell.networkLabel.text = transModel.chainName
        cell.statusImageView.image = UIImage(named: "transaction_success")
        if transModel.value.first == "+" {
            cell.addressLabel.text = transModel.from
        } else {
            cell.addressLabel.text = transModel.to
        }
        return cell
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
