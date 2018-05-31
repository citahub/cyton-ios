//
//  SelectWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SelectWalletController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var selectTable: UITableView!
    @IBOutlet weak var wView: UIView!
    @IBOutlet weak var headLable: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        headLable.isUserInteractionEnabled = true
        selectTable.dataSource = self
        selectTable.delegate = self
        selectTable.tableFooterView = UIView.init()
        

    }

    @IBAction func didClickCloseBtn(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: ID)
//            let lineV = UIView.init(frame: CGRect(x: 15, y: 49, width: wView.frame.size.width - 15, height: 1))
//            lineV.backgroundColor = ColorFromString(hex: lineColor)
//            cell?.contentView.addSubview(lineV)
        }
        
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell?.textLabel?.textColor = ColorFromString(hex: "#333333")
        cell?.textLabel?.text = "我是钱包"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.removeFromSuperview()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
