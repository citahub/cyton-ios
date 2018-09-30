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

class WalletViewController: UITableViewController, SelectWalletControllerDelegate {
    @IBOutlet var titleView: UIView!
    @IBOutlet var tabHeader: UIView!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var totleCurrencyLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!
    @IBOutlet weak var switchWalletButtonItem: UIBarButtonItem!
    @IBOutlet weak var requestPaymentButtonItem: UIBarButtonItem!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    private var tokensViewController: TokensViewController!
    private var nftViewController: UIViewController!
    private var assetPageViewController: UIPageViewController!
    private var isHeaderViewHidden = false {
        didSet {
            updateNavigationBar()
        }
    }

    let viewModel = SubController2ViewModel()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isHeaderViewHidden ? .default : .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didGetDataForCurrentWallet()
        updateNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true
        addNotify()
        tokensViewController = storyboard!.instantiateViewController(withIdentifier: "tokensViewController") as? TokensViewController
        tokensViewController.delegate = self
        nftViewController = storyboard!.instantiateViewController(withIdentifier: "nftViewController")
        assetPageViewController.setViewControllers([tokensViewController], direction: .forward, animated: false)
        assetPageViewController.dataSource = self
        assetPageViewController.delegate = self
        let mjheader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        mjheader?.lastUpdatedTimeLabel.isHidden = true
        tableView.mj_header = mjheader
        tabbedButtonView.buttonTitles = ["代币", "藏品"]
        tabbedButtonView.delegate = self
    }

    @objc
    func endRefresh() {
        tableView.mj_header.endRefreshing()
    }

    @objc
    func loadData() {
        NotificationCenter.default.post(name: .beginRefresh, object: self, userInfo: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedAssetPages" {
            assetPageViewController = segue.destination as? UIPageViewController
        }
        if segue.identifier == "requestPayment" {
            let requestPaymentViewController = segue.destination as! RequestPaymentViewController
            let appModel = WalletRealmTool.getCurrentAppModel()
            requestPaymentViewController.appModel = appModel
        }
        if segue.identifier == "switchWallet" {
            let navigationController = segue.destination as! UINavigationController
            let selectWalletController = navigationController.topViewController as! SelectWalletController
            selectWalletController.delegate = self
        }
    }

    @IBAction func copyWalletAddress(_ sender: UITapGestureRecognizer) {
        copyAddress()
    }

    @IBAction func copyWalletAddressWithButton(_ sender: UIButton) {
        copyAddress()
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
        [tokensViewController, nftViewController].forEach { listViewController in
            (listViewController as? UITableViewController)?.tableView.isScrollEnabled = isHeaderViewHidden
        }
    }

    private func copyAddress() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        UIPasteboard.general.string = appModel.currentWallet?.address
        NeuLoad.showToast(text: "地址已经复制到粘贴板")
    }

    private func updateNavigationBar() {
        if isHeaderViewHidden {
            navigationItem.rightBarButtonItems = [switchWalletButtonItem]
            navigationItem.title = viewModel.getCurrentModel().currentWallet?.name
            navigationItem.titleView = nil
        } else {
            navigationItem.rightBarButtonItems = [requestPaymentButtonItem]
            navigationItem.titleView = titleView
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeWallet(nofy:)), name: .createWalletSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endRefresh), name: .endRefresh, object: nil)
    }

    func didGetDataForCurrentWallet() {
        if WalletRealmTool.hasWallet() {
            let walletModel = viewModel.getCurrentModel().currentWallet!
            refreshUI(walletModel: walletModel)
            loadData()
        }
    }

    //switch wallet delegate
    func selectWalletController(_ controller: SelectWalletController, didSelectWallet model: WalletModel) {
        didGetDataForCurrentWallet()
        NotificationCenter.default.post(name: .switchWallet, object: self, userInfo: nil)
    }

    @objc func changeWallet(nofy: Notification) {
        let wAddress = nofy.userInfo!["post"]
        let walletModel = viewModel.didGetWalletMessage(walletAddress: wAddress as! String)
        refreshUI(walletModel: walletModel)
    }

    func refreshUI(walletModel: WalletModel) {
        name.text = walletModel.name
        address.text = walletModel.address
        icon.image = UIImage(data: walletModel.iconData)
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
}

extension WalletViewController: TabbedButtonsViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, TokensViewControllerDelegate {
    func getCurrentCurrencyModel(currencyModel: LocalCurrency, totleCurrency: Double) {
        totleCurrencyLabel.text = "总资产(\(currencyModel.name))"
        currencyBalanceLabel.text = String(format: "%.2f", totleCurrency)
    }

    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        let viewControllerToShow = index == 0 ? tokensViewController : nftViewController
        assetPageViewController.setViewControllers([viewControllerToShow!], direction: .forward, animated: false)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == nftViewController {
            return tokensViewController
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == tokensViewController {
            return nftViewController
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if previousViewControllers.first == tokensViewController {
                tabbedButtonView.selectedIndex = 1
            } else {
                tabbedButtonView.selectedIndex = 0
            }
        }
    }
}
