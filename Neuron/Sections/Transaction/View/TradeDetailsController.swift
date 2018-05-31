//
//  TradeDetailsController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TradeDetailsController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    let titleArr = ["区块链网络","接受方","发送方","手续费","Gas价格","交易流水号","所在区块","入块时间"]
    let subBtnArr = ["Ethereum Mainnet(或CITA ChainID)","0x12345678964573826483","0x12345678964573826483","0.0005eth","0.000215 eth/gas","0x1234556754356324567532245","12007","2018-3-23  12:30:12"]//测试数据
    
    
    
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var tTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        didSetUIDetail()
        tTable.delegate = self
        tTable.dataSource = self
        tTable.register(UINib.init(nibName: "TradeTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
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
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! TradeTableViewCell
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
