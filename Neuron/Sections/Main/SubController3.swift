//
//  SubController3.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SubController3: BaseViewController,UITableViewDelegate,UITableViewDataSource {


    @IBOutlet weak var sTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易"
        sTable.delegate = self
        sTable.dataSource = self
        sTable.register(UINib.init(nibName: "Sub3TableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        sTable.tableFooterView = UIView.init()

    }

    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! Sub3TableViewCell
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tCtrl = TradeDetailsController.init(nibName: "TradeDetailsController", bundle: nil)
        navigationController?.pushViewController(tCtrl, animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
