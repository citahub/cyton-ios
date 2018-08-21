//
//  ContractController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ContractController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let headArray = ["请求人", "接收地址", "转账金额", "费用总计（含手续费）"]
    let textArray = ["https://www.cryptape.com/#/about", "0xCB5A05beF3257613E984C17DbcF03", "0.05", "0.05"]//假数据
    let unitArray = ["", "", "eth", "eth"]

    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var cTable: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合约调用"
        didSetUIDetail()
        cTable.delegate = self
        cTable.dataSource = self
        cTable.register(UINib.init(nibName: "ContractTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        cTable.register(UINib.init(nibName: "ConTractLastTableViewCell", bundle: nil), forCellReuseIdentifier: "ID1")
    }

    func didSetUIDetail() {
        headView.layer.shadowColor = ColorFromString(hex: "#ededed").cgColor
        headView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headView.layer.shadowOpacity = 0.3
        headView.layer.shadowRadius = 2.75
        headView.layer.cornerRadius = 5
        headView.layer.borderWidth = 1
        headView.layer.borderColor = ColorFromString(hex: "#ededed").cgColor
        backButton.layer.borderColor = ColorFromString(hex: "#2764fe").cgColor
    }
    //提交和返回按钮
    @IBAction func didClickSubmitButton(_ sender: UIButton) {

    }

    @IBAction func didClickBackButton(_ sender: UIButton) {
    }

    //tableview代理
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return 180
        } else {
            return 95
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! ConTractLastTableViewCell

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! ContractTableViewCell
            cell.headLabStr = headArray[indexPath.row]
            cell.textFieldStr = textArray[indexPath.row]
            cell.unitLabStr = unitArray[indexPath.row]
            return cell
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
