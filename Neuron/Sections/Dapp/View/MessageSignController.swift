//
//  MessageSignController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class MessageSignController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var mTable: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subMitButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.frame = CGRect(x: 0, y: ScreenH, width: ScreenW, height: ScreenH)
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        }, completion: { (_) in
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.borderColor = ColorFromString(hex: "#2764fe").cgColor
        mTable.delegate = self
        mTable.dataSource = self
        mTable.register(UINib.init(nibName: "ContractTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        mTable.register(UINib.init(nibName: "ConTractLastTableViewCell", bundle: nil), forCellReuseIdentifier: "ID1")

    }
    //提交返回按钮的点击事件
    @IBAction func didClickSubmitBtn(_ sender: UIButton) {
    }

    @IBAction func didClickBackBtn(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }

    //tableview代理
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 95
        } else {
            return 180
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! ContractTableViewCell
            cell.headLabStr = "请求人"
            cell.textFieldStr = "https://www.cryptape.com/#/about"

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! ConTractLastTableViewCell
            cell.headLable.text = "签名信息"
            cell.hexStr = "The Message To Be Signed"
            cell.UTF8Str = "utf8-The Message To Be Signed"

            return cell
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
