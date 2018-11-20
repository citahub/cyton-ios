//
//  WalletViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import Web3swift
import BigInt
import PullToRefresh

class WalletViewController: UITableViewController, SelectWalletControllerDelegate {
    @IBOutlet var titleView: UIView!
    @IBOutlet var tabHeader: UIView!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var totleCurrencyLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!
    @IBOutlet weak var switchWalletButtonItem: UIBarButtonItem!
    @IBOutlet var scanBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var requestPaymentButtonItem: UIBarButtonItem!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var switchWalletButton: UIButton!
    private var tokensViewController: TokensViewController!
    private var nftViewController: UIViewController!
    private var assetPageViewController: UIPageViewController!
    private var isHeaderViewHidden = false {
        didSet {
            updateNavigationBar()
        }
    }
    let refresher = PullToRefresh()

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
        tableView.addPullToRefresh(refresher) {
            self.loadData()
        }
        tabbedButtonView.buttonTitles = ["代币", "藏品"]
        tabbedButtonView.delegate = self
    }

    @objc private func endRefresh() {
        tableView.endRefreshing(at: .top)
    }

    private func loadData() {
        NotificationCenter.default.post(name: .beginRefresh, object: nil)
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
            let selectWalletController = segue.destination as! SelectWalletController
            selectWalletController.delegate = self
        }
    }

    @IBAction func copyWalletAddress(_ sender: UITapGestureRecognizer) {
        copyAddress()
    }

    @IBAction func copyWalletAddressWithButton(_ sender: UIButton) {
        copyAddress()
    }

    @IBAction func scanQRCode(_ sender: Any) {
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        navigationController?.pushViewController(qrCodeViewController, animated: true)
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
        Toast.showToast(text: "地址已经复制到粘贴板")
    }

    private func updateNavigationBar() {
        if isHeaderViewHidden {
            navigationItem.rightBarButtonItems = [switchWalletButtonItem]
            navigationItem.title = WalletRealmTool.getCurrentAppModel().currentWallet?.name
            navigationItem.titleView = nil
        } else {
            navigationItem.rightBarButtonItems = [requestPaymentButtonItem]
            navigationItem.titleView = titleView
        }
        setNeedsStatusBarAppearanceUpdate()
        if WalletRealmTool.getCurrentAppModel().wallets.count == 1 {
            switchWalletButton.setTitle("添加钱包", for: .normal)
            switchWalletButton.setImage(UIImage(named: "add_wallet_icon")!, for: .normal)
        } else {
            switchWalletButton.setTitle("切换钱包", for: .normal)
            switchWalletButton.setImage(UIImage(named: "switch_wallet_icon")!, for: .normal)
        }
    }

    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeWallet(notification:)), name: .createWalletSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endRefresh), name: .endRefresh, object: nil)
    }

    func didGetDataForCurrentWallet() {
        if WalletRealmTool.hasWallet() {
            let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
            refreshUI(walletModel: walletModel)
            loadData()
        }
    }

    //switch wallet delegate
    func selectWalletController(_ controller: SelectWalletController, didSelectWallet model: WalletModel) {
        didGetDataForCurrentWallet()
        NotificationCenter.default.post(name: .switchWallet, object: nil)
    }

    @objc private func changeWallet(notification: Notification) {
        let address = notification.userInfo!["address"] as! String
        let walletModel = WalletRealmTool.getCreatWallet(walletAddress: address)
        refreshUI(walletModel: walletModel)
    }

    func refreshUI(walletModel: WalletModel) {
        name.text = walletModel.name
        address.text = walletModel.address
        icon.image = UIImage(data: walletModel.iconData)
    }

    // MAKR: - UITableView Delegate
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

    deinit {
        tableView.removePullToRefresh(at: .top)
    }
}

extension WalletViewController: QRCodeViewControllerDelegate {
    func didBackQRCodeMessage(codeResult: String) {
        guard let token = WalletRealmTool.getCurrentAppModel().nativeTokenList.first(where: { $0.symbol == "ETH" }) else {
            return
        }
        let controller: SendTransactionViewController = UIStoryboard(name: .sendTransaction).instantiateViewController()
        controller.token = token
        controller.recipientAddress = codeResult // TODO: At least do address validation here?
        navigationController?.pushViewController(controller, animated: true)
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
