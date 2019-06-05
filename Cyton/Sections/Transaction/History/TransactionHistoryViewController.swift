//
//  TransactionHistoryViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import WebKit

class TransactionHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorOverlayPresentable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tokenProfleView: UIView!
    @IBOutlet private weak var tokenIconView: UIImageView!
    @IBOutlet private weak var tokenNameLabel: UILabel!
    @IBOutlet private weak var tokenOverviewLabel: UILabel!
    @IBOutlet private weak var tokenAmountLabel: UILabel!
    @IBOutlet private var warningView: UIView!
    @IBOutlet private weak var warningHeight: NSLayoutConstraint!
    @IBOutlet private weak var walletQRCodeButton: UIButton!
    @IBOutlet private weak var transactionButton: UIButton!
    @IBOutlet private weak var testTokenWarnLabel: UILabel!
    @IBOutlet private weak var detailsTitleLabel: UILabel!

    private var presenter: TransactionHistoryPresenter?
    private var transactions = [TransactionDetails]()
    var token: Token!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = token.symbol
        walletQRCodeButton.setTitle("Wallet.receipt".localized(), for: .normal)
        transactionButton.setTitle("Wallet.transaction".localized(), for: .normal)
        testTokenWarnLabel.text = "Transaction.History.testTokenWarning".localized()
        detailsTitleLabel.text = "Transaction.History.details".localized()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)

        setupTokenProfile(tokenIcon: nil, overview: nil, price: nil)
        tokenProfleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickTokenProfile)))
        if token.symbol == "MBA" ||
            token.symbol == "CTT" {
            warningView.isHidden = false
            warningHeight.constant = 30.0
        } else {
            warningView.isHidden = true
            warningHeight.constant = 0.0
        }

        presenter = TransactionHistoryPresenter(token: token)
        presenter?.delegate = self
        Toast.showHUD()
        DispatchQueue.global().async {
            switch self.token.type {
            case .ether, .erc20:
                let result = try? EthereumTokenProfileLoader().loadTokenProfile(address: self.token.address)
                let price = TokenPriceLoader().getPrice(symbol: self.token.symbol)
                DispatchQueue.main.async {
                    self.setupTokenProfile(tokenIcon: result?.0, overview: result?.1, price: price)
                }
            default:
                break
            }
            self.loadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendTransaction" {
            let controller = segue.destination as! SendTransactionViewController
            controller.token = presenter?.token
        }
    }

    @objc func clickTokenProfile() {
        let urlString: String
        switch token.type {
        case .ether:
            urlString = "https://ntp.staging.cryptape.com?coin=ethereum"
        case .erc20:
            urlString = "https://ntp.staging.cryptape.com?token=\(token.address)"
        default:
            return
        }
        let controller: BrowserViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
        controller.requestUrlStr = urlString
        let price = tokenAmountLabel.text ?? ""
        controller.webView.configuration.userContentController.addUserScript(WKUserScript(source: "handlePrice('\(price)')", injectionTime: .atDocumentEnd, forMainFrameOnly: false))
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

    private func setupTokenProfile(tokenIcon: String?, overview: String?, price: Double?) {
        guard var tokenIcon = tokenIcon, let overview = overview else {
            overlay.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: tableView.bounds.size.height)
            tokenProfleView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 1)
            tokenProfleView.isHidden = true
            return
        }
        overlay.frame = CGRect(x: 0, y: 125, width: view.bounds.size.width, height: tableView.bounds.size.height)
        tokenProfleView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 125)
        tokenProfleView.isHidden = false
        tokenNameLabel.text = token.symbol
        tokenOverviewLabel.text = {
            let textFont = tokenOverviewLabel.font!
            var formatOverview = overview
            func overviewWidth() -> CGFloat {
                let rect = CGSize(width: 1000, height: textFont.lineHeight)
                return NSString(string: formatOverview).boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [.font: textFont], context: nil).size.width
            }
            while overviewWidth() > tokenOverviewLabel.bounds.size.width * 1.7 {
                let index = formatOverview.index(formatOverview.endIndex, offsetBy: -6)
                formatOverview = String(formatOverview[...index])
            }
            if overview.count != formatOverview.count {
                formatOverview += "..."
            }
            return formatOverview
        }()
        tokenIconView.sd_setImage(with: URL(string: tokenIcon), placeholderImage: UIImage(named: "eth_logo"))
        if let price = price {
            tokenAmountLabel.text = NSDecimalNumber(value: price).currencyFormat()
        } else {
            tokenAmountLabel.text = ""
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        cell.transaction = transactions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > transactions.count - 2 {
            presenter?.loadMoreData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller: TransactionDetailsViewController = UIStoryboard(name: .transactionDetails).instantiateViewController()
        controller.transaction = transactions[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension TransactionHistoryViewController: TransactionHistoryPresenterDelegate {
    func updateTransactions(transaction: [TransactionDetails], updates: [Int], error: Error?) {
        var indexPaths = [IndexPath]()
        for index in updates {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        self.transactions = transaction
        self.tableView.reloadRows(at: indexPaths, with: .none)
    }

    func didLoadTransactions(transaction: [TransactionDetails], insertions: [Int], error: Error?) {
        self.tableView.refreshControl?.endRefreshing()
        self.transactions = transaction

        if transactions.count == 0 {
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
            let contentOffset = self.tableView.contentOffset
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: .none)
            self.tableView.endUpdates()
            self.tableView.setContentOffset(contentOffset, animated: true)
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
            let amount = transaction.value.toAmountText(transaction.token.decimals)
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
                statusLabel.text = "TransactionStatus.success".localized()
                statusLabel.textColor = UIColor(red: 56/255.0, green: 193/255.0, blue: 137/255.0, alpha: 1)
            case .pending:
                statusLabel.text = "TransactionStatus.pending".localized()
                statusLabel.textColor = UIColor(red: 108/255.0, green: 113/255.0, blue: 132/255.0, alpha: 1)
            case .failure:
                statusLabel.text = "TransactionStatus.failure".localized()
                statusLabel.textColor = UIColor(red: 255/255.0, green: 69/255.0, blue: 69/255.0, alpha: 1)
            }
        }
    }
}
