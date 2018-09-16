//
//  TransactionViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import LYEmptyView

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var transactionTableView: UITableView!
    let service = TransactionServiceImp()
    var dataArray: [TransactionModel] = []
    var tokenType: TokenType = .erc20Token
    var tokenModel = TokenModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易列表"
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        transactionTableView.ly_emptyView = LYEmptyView.empty(withImageStr: "emptyData", titleStr: "您还没有交易数据", detailStr: "")
        let mjheader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        mjheader?.lastUpdatedTimeLabel.isHidden = true
        transactionTableView.mj_header = mjheader
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestPayment" {
            let requestPaymentViewController = segue.destination as! RequestPaymentViewController
            let appModel = WalletRealmTool.getCurrentAppmodel()
            requestPaymentViewController.appModel = appModel
        }
        if segue.identifier == "payment" {
            let paymentViewController = segue.destination as! PaymentViewController
            paymentViewController.tokenType = tokenType
            paymentViewController.tokenModel = tokenModel
        }
    }

    @IBAction func didClickPay(_ sender: UIButton) {
//        let tCtrl =  TAViewController.init(nibName: "TAViewController", bundle: nil)
//        tCtrl.tokenModel = tokenModel
//        navigationController?.pushViewController(tCtrl, animated: true)
    }

    @objc func loadData() {
        switch tokenType {
        case .ethereumToken:
            didGetEthTranscationData()
        case .nervosToken:
            didGetNervosTranscationData()
        case .erc20Token:
            transactionTableView.reloadData()
            self.transactionTableView.mj_header.endRefreshing()
        }
    }

    func didGetEthTranscationData() {
        dataArray.removeAll()
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet
        service.didGetETHTransaction(walletAddress: (walletModel?.address)!) { (result) in
            switch result {
            case .Success(let ethArray):
                self.dataArray = ethArray
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            self.transactionTableView.mj_header.endRefreshing()
        }
    }

    func didGetNervosTranscationData() {
        dataArray.removeAll()
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet
        service.didGetNervosTransaction(walletAddress: (walletModel?.address)!) { (result) in
            switch result {
            case .Success(let nervosArray):
                self.dataArray.append(contentsOf: nervosArray)
                self.transactionTableView.reloadData()
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            self.transactionTableView.mj_header.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionTableviewCell
        let transModel = dataArray[indexPath.row]
        cell.addressLabel.text = transModel.hashString
        cell.dateLabel.text = transModel.formatTime
        cell.exchangeLabel.text = transModel.value
        cell.networkLabel.text = transModel.chainName
        if transModel.value.first == "+" {
            cell.statusImageView.image = UIImage(named: "transaction_success")
        } else {
            cell.statusImageView.image = UIImage(named: "transaction_failed")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transModel = dataArray[indexPath.row]
        let tCtrl = TradeDetailsController.init(nibName: "TradeDetailsController", bundle: nil)
        tCtrl.tModel = transModel
        navigationController?.pushViewController(tCtrl, animated: true)
    }

}

enum TokenType {
    case ethereumToken
    case nervosToken
    case erc20Token
}
