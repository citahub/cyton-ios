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

class WalletViewController: UITableViewController, QRCodeControllerDelegate, SelectWalletControllerDelegate {
    @IBOutlet var titleView: UIView!
    @IBOutlet var tabHeader: UIView!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var switchWalletButtonItem: UIBarButtonItem!
    @IBOutlet weak var scanQRButtonItem: UIBarButtonItem!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    private var tokensViewController: UIViewController!
    private var nfcViewController: UIViewController!
    private var assetPageViewController: UIPageViewController!
    private var isHeaderViewHidden = false {
        didSet {
            updateNavigationBar()
        }
    }

    var viewModel = SubController2ViewModel()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isHeaderViewHidden ? .default : .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didGetDataForCurrentWallet()
        updateNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isDarkStyle = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true
        addNotify()
        tokensViewController = storyboard!.instantiateViewController(withIdentifier: "tokensViewController")
        nfcViewController = storyboard!.instantiateViewController(withIdentifier: "nfcViewController")
        assetPageViewController.setViewControllers([tokensViewController], direction: .forward, animated: false)
        assetPageViewController.dataSource = self
        assetPageViewController.delegate = self

        tabbedButtonView.buttonTitles = ["代币", "藏品"]
        tabbedButtonView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedAssetPages" {
            assetPageViewController = segue.destination as? UIPageViewController
        }
        if segue.identifier == "requestPayment" {
            let requestPaymentViewController = segue.destination as! RequestPaymentViewController
            let appModel = WalletRealmTool.getCurrentAppmodel()
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
    
    @IBAction func scanQRCode(_ sender: UIBarButtonItem) {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
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
        [tokensViewController, nfcViewController].forEach { listViewController in
            (listViewController as? UITableViewController)?.tableView.isScrollEnabled = isHeaderViewHidden
        }
    }

    private func copyAddress() {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        UIPasteboard.general.string = appModel.currentWallet?.address
        NeuLoad.showToast(text: "地址已经复制到粘贴板")
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

    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeWallet(nofy:)), name: .creatWalletSuccess, object: nil)
    }

    func didGetDataForCurrentWallet() {
        if WalletRealmTool.hasWallet() {
            let walletModel = viewModel.getCurrentModel().currentWallet!
            refreshUI(walletModel: walletModel)
        }
    }

    //switch wallet delegate
    func selectWalletController(_ controller: SelectWalletController, didSelectWallet model: WalletModel) {
        refreshUI(walletModel: model)
    }

    @objc func changeWallet(nofy: Notification) {
        let wAddress = nofy.userInfo!["post"]
        print(wAddress as! String)
        let walletModel = viewModel.didGetWalletMessage(walletAddress: wAddress as! String)
        refreshUI(walletModel: walletModel)
    }

    func refreshUI(walletModel: WalletModel) {
        name.text = walletModel.name
        address.text = walletModel.address
        icon.image = UIImage(data: walletModel.iconData)
    }

    //TODO: how to deal with qrcode result?
    func didBackQRCodeMessage(codeResult: String) {
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

extension WalletViewController: TabbedButtonsViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        let viewControllerToShow = index == 0 ? tokensViewController : nfcViewController
        assetPageViewController.setViewControllers([viewControllerToShow!], direction: .forward, animated: false)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == nfcViewController {
            return tokensViewController
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == tokensViewController {
            return nfcViewController
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
