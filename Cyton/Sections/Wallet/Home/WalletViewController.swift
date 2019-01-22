//
//  WalletViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class WalletViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var tableHeadView: UIView!
    @IBOutlet private weak var tokenTitleLabel: UILabel!
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var addTokenButton: UIButton!
    @IBOutlet private var addWalletBarButton: UIBarButtonItem!
    @IBOutlet private var switchWalletBarButton: UIBarButtonItem!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var totalAmountLabel: UILabel!
    @IBOutlet weak var receiptButton: DesignableButton!
    @IBOutlet weak var transactionButton: DesignableButton!

    @IBOutlet weak var tokenTitleWidthLayout: NSLayoutConstraint!

    private var presenter: WalletPresenter!
    private var walletCountObserve: NotificationToken?
    private var walletObserver: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        localization()
        tableView.contentInsetAdjustmentBehavior = .never

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(WalletViewController.refresh), for: .valueChanged)
        tableView.refreshControl = refresh

        presenter = WalletPresenter()
        presenter.delegate = self
        presenter.refresh()

        // observe wallet count
        let realm = try! Realm()
        walletCountObserve = realm.objects(WalletModel.self).observe { [weak self](_) in
            if realm.objects(WalletModel.self).count > 1 {
                self?.navigationItem.rightBarButtonItem = self?.switchWalletBarButton
            } else {
                self?.navigationItem.rightBarButtonItem = self?.addWalletBarButton
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if presenter.refreshing {
            beganRefreshButtonAnimation()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transactionHistory" {
            let controller = segue.destination as! TransactionHistoryViewController
            controller.token = sender as? Token
        } else if segue.identifier == "transaction" {
            let controller = segue.destination as! SendTransactionViewController
            controller.enableSwitchToken = true
        }
    }

    // MARK: - Actions
    @IBAction func refresh() {
        guard !presenter.refreshing else { return }
        presenter.refreshBalance()
    }

    func localization() {
        title = "Wallet".localized()
        tokenTitleLabel.text = "Wallet.token".localized()
        addTokenButton.setTitle("Wallet.addToken".localized(), for: .normal)
        receiptButton.setTitle(" " + "Wallet.receipt".localized(), for: .normal)
        transactionButton.setTitle(" " + "Wallet.transaction".localized(), for: .normal)

        tokenTitleWidthLayout.constant = tokenTitleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: 200, height: 25), limitedToNumberOfLines: 1).size.width
    }
}

extension WalletViewController: WalletPresenterDelegate {
    func walletPresenter(presenter: WalletPresenter, didRefreshTokenAmount token: Token) {
        guard let index = presenter.tokens.lastIndex(where: { $0 == token }) else { return }
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tableView.endUpdates()
    }

    func walletPresenter(presenter: WalletPresenter, didRefreshToken tokens: [Token]) {
        tableView.reloadData()
    }

    func walletPresenter(presenter: WalletPresenter, didRefreshCurrency currency: LocalCurrency) {
        if Locale.current.languageCode?.contains("zh") ?? false {
            currencyLabel.text = "Wallet.totalAmount".localized() + "(\(currency.name))"
        } else {
            currencyLabel.text = "Wallet.totalAmount".localized() + "(\(currency.short))"
        }
    }

    func walletPresenter(presenter: WalletPresenter, didSwitchWallet wallet: WalletModel) {
        totalAmountLabel.text = "- - -"
        walletObserver?.invalidate()
        walletObserver = wallet.observe({ [weak self](change) in
            switch change {
            case .change(let propertys):
                guard let name = propertys.first(where: { $0.name == "name" })?.newValue as? String else { return }
                self?.navigationItem.title = name
            default:
                break
            }
        })
    }

    func walletPresenter(presenter: WalletPresenter, didRefreshTotalAmount amount: NSDecimalNumber) {
        if amount == 0.0 {
            totalAmountLabel.text = "Wallet.noAmount".localized()
        } else {
            totalAmountLabel.text = "≈\(presenter.currency.symbol)" + amount.currencyFormat()
        }
    }

    func walletPresenterBeganRefresh(presenter: WalletPresenter) {
        beganRefreshButtonAnimation()
    }

    func walletPresenterEndedRefresh(presenter: WalletPresenter) {
        if tableView.refreshControl!.isRefreshing {
            tableView.refreshControl?.endRefreshing()
        }
        endRefreshButtonAnimation()
    }
}

extension WalletViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let token = presenter.tokens[indexPath.row]
        let cell: TokenTableViewCell
        if token.balance == nil {
            if presenter.refreshing {
                cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell_Loading") as! TokenTableViewCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell_LoadFail") as! TokenTableViewCell
            }
        } else if token.price == nil || token.balance == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell_NoPrice") as! TokenTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell") as! TokenTableViewCell
        }
        cell.token = presenter.tokens[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeadView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "transactionHistory", sender: presenter.tokens[indexPath.row])
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshButton.alpha = 1 - scrollView.contentOffset.y / -125
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshButton.alpha = 1.0
        tableView.refreshControl?.endRefreshing()
    }
}

extension WalletViewController {
    func beganRefreshButtonAnimation() {
        guard (refreshButton.layer.animationKeys()?.count ?? 0) <= 0 else { return }
        UIView.beginAnimations("refresh", context: nil)
        UIView.setAnimationDuration(0.4)
        UIView.setAnimationRepeatCount(Float(Int.max))
        UIView.setAnimationCurve(.linear)
        refreshButton.transform = refreshButton.transform.rotated(by: CGFloat(Double.pi))
        UIView.commitAnimations()
        tableView.reloadData()
    }
    func endRefreshButtonAnimation() {
        refreshButton.layer.removeAllAnimations()
        tableView.reloadData()
    }
}
