//
//  TransactionViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import PullToRefresh
import WebKit

class TransactionHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorOverlayPresentable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tokenProfleView: UIView!
    @IBOutlet weak var tokenIconView: UIImageView!
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var tokenOverviewLabel: UILabel!
    @IBOutlet weak var tokenAmountLabel: UILabel!
    @IBOutlet var warningView: UIView!
    @IBOutlet weak var warningHeight: NSLayoutConstraint!

    var service: TransactionHistoryService?
    var tokenProfile: TokenProfile?
    var tokenType: TokenType = .erc20
    var tokenModel: TokenModel! {
        didSet {
            guard tokenModel != nil else { return }
            service = TransactionHistoryService.service(with: tokenModel)
            Toast.showHUD()
            loadData()
        }
    }
    let refresher = PullToRefresh()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易列表"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addPullToRefresh(refresher) {
            self.loadData()
        }
        setupTokenProfile(nil)

        tokenProfleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickTokenProfile)))
        if tokenModel.symbol == "MBA" ||
            tokenModel.symbol == "NATT" {
            warningView.isHidden = false
            warningHeight.constant = 30.0
        } else {
            warningView.isHidden = true
            warningHeight.constant = 0.0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestPayment" {
            let requestPaymentViewController = segue.destination as! RequestPaymentViewController
            let appModel = WalletRealmTool.getCurrentAppModel()
            requestPaymentViewController.appModel = appModel
        } else if segue.identifier == "sendTransaction" {
            let controller = segue.destination as! SendTransactionViewController
            controller.token = service?.token
        }
    }

    @objc func clickTokenProfile() {
        guard let url = tokenProfile?.detailUrl else { return }
        let controller: BrowserViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
        controller.requestUrlStr = url.absoluteString
        let js = "window.webkit.messageHandlers.getTokenPrice.postMessage({symbol: 'ETH', callback: 'handlePrice'})"
        controller.webView.configuration.userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        controller.webView.addMessageHandler(name: "getTokenPrice") { [weak self](message) in
            guard message.name == "getTokenPrice" else { return }
            let currency = LocalCurrencyService.shared.getLocalCurrencySelect()
            let price = String(format: "%@ %.2f", currency.symbol, self?.tokenProfile?.price ?? 0.0)
            message.webView?.evaluateJavaScript("handlePrice('\(price)')", completionHandler: nil)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    private func loadData() {
        let group = DispatchGroup()
        var profile: TokenProfile?

        group.enter()
        service?.reloadData { (_) in
            group.leave()
        }

        group.enter()
        tokenModel.getProfile { (tokenProfile) in
            profile = tokenProfile
            group.leave()
        }

        group.notify(queue: .main) {
            Toast.hideHUD()
            self.setupTokenProfile(profile)
            self.tableView.endRefreshing(at: .top)
            self.tableView.reloadData()
            if self.service?.transactions.count == 0 {
                self.errorOverlaycontroller.style = .blank
                self.tableView.addSubview(self.overlay)
            } else {
                self.removeOverlay()
            }
        }
    }

    private func setupTokenProfile(_ profile: TokenProfile?) {
        tokenProfile = profile
        guard var profile = profile else {
            self.overlay.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)
            self.tokenProfleView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 1)
            self.tokenProfleView.isHidden = true
            return
        }
        self.overlay.frame = CGRect(x: 0, y: 125, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)
        self.tokenProfleView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 125)
        self.tokenProfleView.isHidden = false
        self.tokenNameLabel.text = profile.symbol

        let textFont = self.tokenOverviewLabel.font!
        var overview = profile.overview.zh
        func overviewWidth() -> CGFloat {
            let rect = CGSize(width: 1000, height: textFont.lineHeight)
            return NSString(string: overview).boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [.font: textFont], context: nil).size.width
        }
        while overviewWidth() > self.tokenOverviewLabel.bounds.size.width * 1.7 {
            let index = overview.index(overview.endIndex, offsetBy: -6)
            overview = String(overview[...index])
        }
        if profile.overview.zh.count != overview.count {
            overview += "..."
        }
        self.tokenOverviewLabel.text = overview

        if let imageUrl = URL(string: profile.imageUrl ?? "") {
            self.tokenIconView.sd_setImage(with: imageUrl) { (image, error, _, _) in
                if image == nil {
                    print(error!)
                }
            }
        } else if let image = profile.image {
            self.tokenIconView.image = image
        }
        self.tokenAmountLabel.text = profile.possess
    }

    private func loadMoreData() {
        service?.loadMoreDate(completion: { [weak self](insertions, _) in
            var indexPaths = [IndexPath]()
            for index in insertions {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: indexPaths, with: .none)
            self?.tableView.endUpdates()
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service?.transactions.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        cell.transaction = service!.transactions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > service!.transactions.count - 6 {
            loadMoreData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = TradeDetailsController(nibName: "TradeDetailsController", bundle: nil)
        controller.tModel = service!.transactions[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }

    deinit {
        tableView.removeAllPullToRefresh()
    }
}

class TransactionHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var transaction: TransactionModel? {
        didSet {
            guard let transaction = transaction else { return }
            dateLabel.text = transaction.formatTime
            let walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
            if transaction.to.lowercased() == walletAddress.lowercased() {
                addressLabel.text = transaction.from
                numberLabel.text = "+\(transaction.value)"
            } else {
                addressLabel.text = transaction.to
                numberLabel.text = "-\(transaction.value)"
            }
        }
    }
}
