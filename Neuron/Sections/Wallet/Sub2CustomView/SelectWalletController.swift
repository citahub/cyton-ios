//
//  SelectWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol SelectWalletControllerDelegate: NSObjectProtocol {
    func didCallBackSelectedWalletModel(walletModel: WalletModel)
}

class SelectWalletController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var selectTable: UITableView!
    @IBOutlet weak var wView: UIView!
    @IBOutlet weak var headLable: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    weak var delegate: SelectWalletControllerDelegate?
    var appModel = AppModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didGetWalletData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        headLable.isUserInteractionEnabled = true
        selectTable.dataSource = self
        selectTable.delegate = self
        selectTable.tableFooterView = UIView.init()
        didGetWalletData()
    }

    @IBAction func didClickCloseBtn(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }

    func didGetWalletData() {
        appModel = WalletRealmTool.getCurrentAppmodel()
        selectTable.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appModel.wallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: ID)
        }

        cell?.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell?.textLabel?.textColor = ColorFromString(hex: "#333333")
        let walletModel = appModel.wallets[indexPath.row]
        cell?.textLabel?.text = walletModel.name
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let walletModel = appModel.wallets[indexPath.row]
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
        }
        delegate?.didCallBackSelectedWalletModel(walletModel: walletModel)
        self.view.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
