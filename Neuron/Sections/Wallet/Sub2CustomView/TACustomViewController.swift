//
//  TACustomViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SCLAlertView
import web3swift
import BigInt

protocol TACustomViewControllerDelegate: class {
    func successPop()
}

class TACustomViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    let titleArray = ["转入地址", "付款钱包", "交易费用"]

    //还没正式接入 数据写死
    var valueArray: [String?] = []
    var gasPrice = BigUInt()

    var amountStr: String = ""{
        didSet {
            countLable.text = amountStr
        }
    }
    var destinationAddress = ""{
        didSet {
            taTable.reloadData()
        }
    }
    var estimatedGas = ""{
        didSet {
            taTable.reloadData()
        }
    }

    var erc20TokenAddress = ""

    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var taTable: UITableView!
    @IBOutlet weak var sureButton: UIButton!

    var ethTransactionService: EthTransactionServiceProtocol!

    let viewModel = TAViewModel()
    var walletModel = WalletModel()
    var passwordMD5 = ""
    weak var delegate: TACustomViewControllerDelegate?

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
        taTable.delegate = self
        taTable.dataSource = self
        countLable.text = amountStr
        walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        passwordMD5 = walletModel.MD5screatPassword
        valueArray = [destinationAddress, walletModel.address, estimatedGas]
        ethTransactionService = erc20TokenAddress == "1" ? EthTransactionServiceImp():ERC20TransactionServiceImp()
    }

    @IBAction func didClickCloseButton(_ sender: UIButton) {
        view.removeFromSuperview()
    }
    //点击发送按钮
    @IBAction func didClickSureSendButton(_ sender: UIButton) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("请输入钱包密码")
        txt.isSecureTextEntry = true
        alert.addButton("确定") {
            txt.resignFirstResponder()
            if self.passwordMD5 != CryptTools.changeMD5(password: txt.text!) {
                NeuLoad.showToast(text: "旧密码错误")
                return
            } else {
                NeuLoad.showHUD(text: "")
                self.ethTransactionService.prepareTransactionForSending(destinationAddressString: self.destinationAddress, amountString: self.amountStr, gasLimit: 21000, walletPassword: txt.text!, gasPrice: self.gasPrice, erc20TokenAddress: self.erc20TokenAddress, completion: { (sendResult) in
                    switch sendResult {
                    case .Success(let value):
                        print(value)
                        self.sendTransaction(password: txt.text!, transaction: value)
                    case .Error(let error):
                        print(error.localizedDescription)
                        NeuLoad.hidHUD()
                    }
                })
            }
        }
        alert.addButton("取消") {

        }
        alert.showEdit("确认交易", subTitle: "请确保您已经确认此次交易信息无误", colorStyle: 0x2e4af2,
                       colorTextButton: 0xFFFFFF)
    }

    func sendTransaction(password: String, transaction: TransactionIntermediate) {
        ethTransactionService.send(password: password, transaction: transaction, completion: { (result) in
            switch result {
            case .Success(let ethTransactionResult):
                print(ethTransactionResult.transaction.description)
                NeuLoad.showToast(text: "转账成功,请稍后刷新查看")
                self.view.removeFromSuperview()
                self.delegate?.successPop()
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            NeuLoad.hidHUD()
        })
    }

    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: ID)
            cell?.textLabel?.textColor = ColorFromString(hex: "#888888")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.detailTextLabel?.textColor = ColorFromString(hex: "#333333")
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.detailTextLabel?.lineBreakMode = .byTruncatingMiddle
        }

        cell?.textLabel?.text = titleArray[indexPath.row]
        switch indexPath.row {
        case 0:
            cell?.detailTextLabel?.text = destinationAddress
        case 1:
            cell?.detailTextLabel?.text = walletModel.address
        case 2:
            cell?.detailTextLabel?.text = estimatedGas
        default:
            break
        }
        return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
