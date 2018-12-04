//
//  TransactionHistoryViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import WebKit
import Web3swift

class TransactionHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorOverlayPresentable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tokenProfleView: UIView!
    @IBOutlet weak var tokenIconView: UIImageView!
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var tokenOverviewLabel: UILabel!
    @IBOutlet weak var tokenAmountLabel: UILabel!
    @IBOutlet var warningView: UIView!
    @IBOutlet weak var warningHeight: NSLayoutConstraint!

    var presenter: TransactionHistoryPresenter?
    var tokenProfile: TokenProfile?
    var tokenType: TokenType = .erc20
    var token: Token!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = token.symbol
        tableView.delegate = self
        tableView.dataSource = self

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)

        setupTokenProfile(nil)
        tokenProfleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickTokenProfile)))
        if token.symbol == "MBA" ||
            token.symbol == "NATT" {
            warningView.isHidden = false
            warningHeight.constant = 30.0
        } else {
            warningView.isHidden = true
            warningHeight.constant = 0.0
        }

        presenter = TransactionHistoryPresenter(token: token)
        presenter?.delegate = self
        Toast.showHUD()
        token.tokenModel.getProfile { (tokenProfile) in
            self.setupTokenProfile(tokenProfile)
            self.presenter?.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendTransaction" {
            let controller = segue.destination as! SendTransactionViewController
            controller.token = presenter?.token.tokenModel
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
            let price = self?.tokenProfile?.priceText ?? ""
            message.webView?.evaluateJavaScript("handlePrice('\(price)')", completionHandler: nil)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func loadData() {
        presenter?.reloadData(completion: { (_, _) in
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            if self.presenter?.transactions.count == 0 {
                self.errorOverlaycontroller.style = .blank
                self.tableView.addSubview(self.overlay)
            } else {
                self.removeOverlay()
            }
            Toast.hideHUD()
        })
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
        self.tokenAmountLabel.text = profile.priceText
    }

    private func loadMoreData() {
        presenter?.loadMoreData(completion: { [weak self](insertions, _) in
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
        return presenter?.transactions.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        cell.transaction = presenter!.transactions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > presenter!.transactions.count - 2 {
            presenter?.loadMoreData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = TradeDetailsController(nibName: "TradeDetailsController", bundle: nil)
        controller.transaction = presenter?.transactions[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension TransactionHistoryViewController: TransactionHistoryPresenterDelegate {
    func updateTransactions(transaction: [TransactionDetails], updates: [Int], error: Error?) {
        var indexPaths = [IndexPath]()
        for index in updates {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        self.tableView.reloadRows(at: indexPaths, with: .none)
    }

    func didLoadTransactions(transaction: [TransactionDetails], insertions: [Int], error: Error?) {
        self.tableView.refreshControl?.endRefreshing()

        if self.presenter?.transactions.count == 0 {
            self.errorOverlaycontroller.style = .blank
            self.tableView.addSubview(self.overlay)
        } else {
            self.removeOverlay()
        }

        if insertions.first == 0 {
            self.tableView.reloadData()
        } else {
            var indexPaths = [IndexPath]()
            for index in insertions {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: .none)
            self.tableView.endUpdates()
        }

        Toast.hideHUD()
    }
}

class TransactionHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var transaction: TransactionDetails? {
        didSet {
            guard let transaction = transaction else { return }
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            dateLabel.text = dateformatter.string(from: transaction.date)

            let walletAddress = AppModel.current.currentWallet!.address
            let amount = Double.fromAmount(transaction.value, decimals: transaction.token.decimals).decimal
            if transaction.from.lowercased() == walletAddress.lowercased() ||
                transaction.from == transaction.to {
                addressLabel.text = transaction.to.count > 0 ? transaction.to : "Contract Created"
                numberLabel.text = "-\(amount)"
            } else {
                addressLabel.text = transaction.from
                numberLabel.text = "+\(amount)"
            }

            switch transaction.status {
            case .success:
                statusLabel.text = "交易成功"
                statusLabel.textColor = UIColor(red: 56/255.0, green: 193/255.0, blue: 137/255.0, alpha: 1)
            case .pending:
                statusLabel.text = "交易进行中"
                statusLabel.textColor = UIColor(red: 108/255.0, green: 113/255.0, blue: 132/255.0, alpha: 1)
            case .failure:
                statusLabel.text = "交易失败"
                statusLabel.textColor = UIColor(red: 255/255.0, green: 69/255.0, blue: 69/255.0, alpha: 1)
            }
        }
    }
}
