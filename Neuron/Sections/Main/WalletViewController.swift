//
//  WalletViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import web3swift
import BigInt
import MJRefresh

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AssetsDetailControllerDelegate, SelectWalletControllerDelegate {
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var namelable: UILabel!
    @IBOutlet weak var mAddress: UILabel!
    @IBOutlet weak var archiveBtn: UIButton!
    @IBOutlet weak var manageBtn: UIButton!
    @IBOutlet weak var mainTable: UITableView!
    let sCtrl = SelectWalletController.init(nibName: "SelectWalletController", bundle: nil)
    let aCtrl = AssetsDetailController.init(nibName: "AssetsDetailController", bundle: nil)

    var viewModel = SubController2ViewModel()
    var tokenArray: [TokenModel] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        didGetDataForCurrentWallet()
        if tokenArray.count != (viewModel.getCurrentModel().currentWallet?.selectTokenList.count)! + WalletRealmTool.getCurrentAppmodel().nativeTokenList.count {
            didGetTokenList()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "钱包"
        automaticallyAdjustsScrollViewInsets = true

        sCtrl.delegate = self
        aCtrl.delegate = self
        addNotify()
        setUpSubViewDetails()

        iconImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didClickIconImage))
        iconImageView.addGestureRecognizer(tap)
    }

    //接收通知
    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeWallet(nofy:)), name: .creatWalletSuccess, object: nil)
    }

    /// 正常情况下进入钱包界面要获取的数据
    func didGetDataForCurrentWallet() {
        if WalletRealmTool.hasWallet() {
            let walletModel = viewModel.getCurrentModel().currentWallet!
            refreshUI(walletModel: walletModel)
        }
    }

    //switch wallet delegate
    func didCallBackSelectedWalletModel(walletModel: WalletModel) {
        refreshUI(walletModel: walletModel)
        didGetTokenList()
    }

    //在当前钱包发生变化之后 UI的更新以及所有数据的更新
    @objc func changeWallet(nofy: Notification) {
        let wAddress = nofy.userInfo!["post"]
        print(wAddress as! String)
        let walletModel = viewModel.didGetWalletMessage(walletAddress: wAddress as! String)
        refreshUI(walletModel: walletModel)
        loadData()
    }

    func refreshUI(walletModel: WalletModel) {
        namelable.text = walletModel.name
        mAddress.text = walletModel.address
        iconImageView.image = UIImage(data: walletModel.iconData)
    }

    /// get token list from realm
    func didGetTokenList() {
        tokenArray.removeAll()
        let appModel = WalletRealmTool.getCurrentAppmodel()
        tokenArray += appModel.nativeTokenList
        let walletModel = viewModel.getCurrentModel().currentWallet!
        for item in walletModel.selectTokenList {
            tokenArray.append(item)
        }
        mainTable.reloadData()
        getBalance(isRefresh: false)
    }

    func getBalance(isRefresh: Bool) {
        let group = DispatchGroup()
        if isRefresh {
        } else {
            NeuLoad.showHUD(text: "")
        }
        let walletModel = viewModel.getCurrentModel().currentWallet!
        for tm in tokenArray {
            if tm.chainId == ETH_MainNetChainId {
                group.enter()
                viewModel.didGetTokenForCurrentwallet(walletAddress: walletModel.address) { (balance, error) in
                    if error == nil {
                        tm.tokenBalance = balance!
                    } else {
                        NeuLoad.showToast(text: (error?.localizedDescription)!)
                    }
                    group.leave()
                }
            } else if tm.chainId != "" && tm.chainId != ETH_MainNetChainId {
                group.enter()
                viewModel.getNervosNativeTokenBalance(walletAddress: walletModel.address) { (balance, error) in
                    if error == nil {
                        tm.tokenBalance = balance!
                    } else {
                        NeuLoad.showToast(text: (error?.localizedDescription)!)
                    }
                    group.leave()
                }
            } else {
                group.enter()
                viewModel.didGetERC20BalanceForCurrentWallet(wAddress: walletModel.address, ERC20Token: tm.address) { (erc20Balance, error) in
                    if error == nil {
                        let balance = Web3.Utils.formatToPrecision(erc20Balance!, numberDecimals: tm.decimals, formattingDecimals: 6, fallbackToScientific: false)
                        tm.tokenBalance = balance!
                    } else {
                        NeuLoad.showToast(text: (error?.localizedDescription)!)
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            self.mainTable.reloadData()
            if isRefresh {
                self.mainTable.mj_header.endRefreshing()
            } else {
                NeuLoad.hidHUD()
            }
        }
    }

    func setUpSubViewDetails() {
        headView.layer.shadowColor = ColorFromString(hex: "#ededed").cgColor
        headView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headView.layer.shadowOpacity = 0.3
        headView.layer.shadowRadius = 2.75
        headView.layer.cornerRadius = 5
        headView.layer.borderWidth = 1
        headView.layer.borderColor = ColorFromString(hex: "#ededed").cgColor

        iconImageView.layer.borderColor = ColorFromString(hex: lineColor).cgColor
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.cornerRadius = 30
        iconImageView.clipsToBounds = true

        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib.init(nibName: "Sub2TableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        let mjheader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        mjheader?.lastUpdatedTimeLabel.isHidden = true
        mainTable.mj_header = mjheader

        //设置左右导航按钮
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        leftBtn.setImage(UIImage.init(named: "列表"), for: .normal)
        leftBtn.addTarget(self, action: #selector(didChangeWallet), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBtn)

        let rightBtn = UIButton.init(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        rightBtn.setImage(UIImage.init(named: "添加"), for: .normal)
        rightBtn.addTarget(self, action: #selector(didAddWallet), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
    }

    @objc func loadData() {
        getBalance(isRefresh: true)
    }

    //点击头部两个按钮
    //收款
    @IBAction func didClickArchiveBtn(_ sender: UIButton) {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        let rCtrl = ReceiveController.init(nibName: "ReceiveController", bundle: nil)
        rCtrl.walletAddress = appModel.currentWallet?.address
        rCtrl.walletName = appModel.currentWallet?.name
        rCtrl.walletIcon = appModel.currentWallet?.iconData
        navigationController?.pushViewController(rCtrl, animated: true)
    }
    //点击资产管理按钮
    @IBAction func didClickManageBtn(_ sender: UIButton) {
        let aCtrl = AssetViewController.init(nibName: "AssetViewController", bundle: nil)
        navigationController?.pushViewController(aCtrl, animated: true)
    }
    //click icon image
    @objc func didClickIconImage() {
        let wCtrl = WalletDetailController.init(nibName: "WalletDetailController", bundle: nil)
        navigationController?.pushViewController(wCtrl, animated: true)
    }

    //switch wallet
    @objc func didChangeWallet() {
        UIApplication.shared.keyWindow?.addSubview(sCtrl.view)
    }

    //新增钱包
    @objc func didAddWallet() {
        let aCtrl = AddWalletController.init(nibName: "AddWalletController", bundle: nil)
        navigationController?.pushViewController(aCtrl, animated: true)
    }

    //弹出界面点击按钮的代理事件
    //点击付款
    func didClickPay(tokenModel: TokenModel) {
        print("付款")
        let tCtrl =  TAViewController.init(nibName: "TAViewController", bundle: nil)
        tCtrl.tokenModel = tokenModel
        navigationController?.pushViewController(tCtrl, animated: true)
    }

    //点击收款
    func didClickGet() {
        print("收款")
        let appModel = WalletRealmTool.getCurrentAppmodel()
        let rCtrl = ReceiveController.init(nibName: "ReceiveController", bundle: nil)
        rCtrl.walletAddress = appModel.currentWallet?.address
        rCtrl.walletName = appModel.currentWallet?.name
        rCtrl.walletIcon = appModel.currentWallet?.iconData
        navigationController?.pushViewController(rCtrl, animated: true)
    }

    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! Sub2TableViewCell
        let tokenModel = tokenArray[indexPath.row]
        cell.titlelable.text = tokenModel.symbol
        cell.iconUrlStr = tokenModel.iconUrl
        cell.countLable.text = tokenModel.tokenBalance
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.keyWindow?.addSubview(aCtrl.view)
        let tokenModel = tokenArray[indexPath.row]
        aCtrl.tokenModel = tokenModel
    }
}
