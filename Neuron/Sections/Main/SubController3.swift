//
//  SubController3.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import LYEmptyView
import MJRefresh

class SubController3: BaseViewController,UITableViewDelegate,UITableViewDataSource {


    let service = TransactionServiceImp()
    
    var dataArray:[TransactionModel] = []
    
    
    @IBOutlet weak var sTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if WalletRealmTool.getCurrentAppmodel().wallets.count != 0 {
            didGetEthTranscationData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易"
        sTable.delegate = self
        sTable.dataSource = self
        sTable.register(UINib.init(nibName: "Sub3TableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        sTable.tableFooterView = UIView.init()
        sTable.ly_emptyView = LYEmptyView.empty(withImageStr: "emptyData", titleStr: "您还没有交易数据", detailStr: "")
        let mjheader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        mjheader?.lastUpdatedTimeLabel.isHidden = true
        sTable.mj_header = mjheader
    }
    
    @objc func loadData(){
        didGetEthTranscationData()
    }
    
    func didGetEthTranscationData() {
        if WalletRealmTool.getCurrentAppmodel().wallets.count != 0 {
            let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet
            service.didGetETHTransaction(walletAddress: (walletModel?.address)!) { (result) in
                switch result{
                case .Success(let ethArray):
                    self.dataArray = ethArray
                    self.didGetNervosTranscationData()
                case .Error(let error):
                    NeuLoad.showToast(text: error.localizedDescription)
                }
            }
        }else{
            sTable.mj_header.endRefreshing()
        }
    }
    
    func didGetNervosTranscationData() {
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet
        service.didGetNervosTransaction(walletAddress: (walletModel?.address)!) { (result) in
            switch result{
            case .Success(let nervosArray):
                self.dataArray.append(contentsOf: nervosArray)
                self.sTable.reloadData()
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            self.sTable.mj_header.endRefreshing()
        }
    }
    
    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! Sub3TableViewCell
        
        let transModel = dataArray[indexPath.row]
        cell.addressLable.text = transModel.hashString
        cell.dataLable.text = transModel.formatTime
        cell.limitLable.text = transModel.value
        cell.exchangeLable.text = transModel.chainName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transModel = dataArray[indexPath.row]
        let tCtrl = TradeDetailsController.init(nibName: "TradeDetailsController", bundle: nil)
        tCtrl.tModel = transModel
        print(transModel.blockNumber)
        navigationController?.pushViewController(tCtrl, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
