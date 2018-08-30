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

class WalletViewController: UITableViewController, AssetsDetailControllerDelegate, SelectWalletControllerDelegate {
    @IBOutlet var titleView: UIView!
    @IBOutlet var tabHeader: UIView!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var switchWalletButtonItem: UIBarButtonItem!
    @IBOutlet weak var scanQRButtonItem: UIBarButtonItem!

    private var assetPageViewController: WalletAssetPageViewController!
    private var isHeaderViewHidden = false {
        didSet {
            updateNavigationBar()
        }
    }

    let sCtrl = SelectWalletController.init(nibName: "SelectWalletController", bundle: nil)
    let aCtrl = AssetsDetailController.init(nibName: "AssetsDetailController", bundle: nil)

    var viewModel = SubController2ViewModel()
    var tokenArray: [TokenModel] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isHeaderViewHidden ? .default : .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        didGetDataForCurrentWallet()
        if tokenArray.count != (viewModel.getCurrentModel().currentWallet?.selectTokenList.count)! + WalletRealmTool.getCurrentAppmodel().nativeTokenList.count {
            didGetTokenList()
        }

        updateNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isDarkStyle = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true

        tabbedButtonView.buttonTitles = ["代币", "藏品"]
        tabbedButtonView.delegate = self

        sCtrl.delegate = self
        aCtrl.delegate = self
        addNotify()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedAssetPages" {
            assetPageViewController = segue.destination as? WalletAssetPageViewController
        }
    }

    @IBAction func unwind(seque: UIStoryboardSegue) { }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            offset += scrollView.adjustedContentInset.top
        } else {
            offset += scrollView.contentInset.top
        }

        isHeaderViewHidden = offset >= tableView.tableHeaderView!.bounds.height
        assetPageViewController.pages.forEach { listViewController in
            (listViewController as? UITableViewController)?.tableView.isScrollEnabled = isHeaderViewHidden
        }
    }

    private func updateNavigationBar() {
        navigationController?.navigationBar.isDarkStyle = !isHeaderViewHidden
        if isHeaderViewHidden {
            navigationItem.rightBarButtonItems = [switchWalletButtonItem]
            title = viewModel.getCurrentModel().currentWallet?.name
            navigationItem.titleView = nil
        } else {
            navigationItem.rightBarButtonItems = [scanQRButtonItem]
            navigationItem.titleView = titleView
        }
        setNeedsStatusBarAppearanceUpdate()
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
        /*
        namelable.text = walletModel.name
        mAddress.text = walletModel.address
        iconImageView.image = UIImage(data: walletModel.iconData)*/
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
        //mainTable.reloadData()
        getBalance(isRefresh: false)
    }

    func getBalance(isRefresh: Bool) {
        let group = DispatchGroup()
        if isRefresh {
        } else {
            //NeuLoad.showHUD(text: "")
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
            //self.mainTable.reloadData()
            if isRefresh {
             //   self.mainTable.mj_header.endRefreshing()
            } else {
                NeuLoad.hidHUD()
            }
        }
    }

    @objc func loadData() {
        getBalance(isRefresh: true)
    }

    // TODO: migrate these actions to storyboards segue
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
        let aCtrl = ManageAssetViewController.init(nibName: "AssetViewController", bundle: nil)
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if #available(iOS 11.0, *) {
            return tableView.frame.height - tabHeader.frame.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom
        } else {
            return tableView.frame.height - tabHeader.frame.height - tableView.contentInset.top - tableView.contentInset.bottom
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tabHeader
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tabHeader.frame.height
    }
    /*
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
    }*/
}

extension WalletViewController: TabbedButtonsViewDelegate {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        // todo
    }
}
