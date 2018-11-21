//
//  WalletViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class WalletViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableHeadView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet var addWalletBarButton: UIBarButtonItem!
    @IBOutlet var switchWalletBarButton: UIBarButtonItem!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!

    private var presenter = WalletPresenter()
    private var walletCountObserve: NotificationToken?
//    private var observers = [NSKeyValueObservation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(WalletViewController.refresh), for: .valueChanged)
        tableView.refreshControl = refresh
        presenter.delegate = self
        presenter.refresh()

        // observe wallet count
        walletCountObserve = WalletRealmTool.realm.objects(WalletModel.self).observe { [weak self](_) in
            if WalletRealmTool.realm.objects(WalletModel.self).count > 1 {
                self?.navigationItem.rightBarButtonItem = self?.switchWalletBarButton
            } else {
                self?.navigationItem.rightBarButtonItem = self?.addWalletBarButton
            }
        }

//        observers.append(presenter.observe(\.currency, options: [.initial]) { (_, _) in
//        })
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    // MARK: - Actions
    @IBAction func refresh() {
        guard !presenter.refreshing else { return }
        presenter.refreshAmount()
    }
    @IBAction func walletQRCode(_ sender: Any) {
    }
    @IBAction func transaction(_ sender: Any) {
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
        currencyLabel.text = "总资产(\(currency.name))"
    }

    func walletPresenter(presenter: WalletPresenter, didSwitchWallet wallet: WalletModel) {
        totalAmountLabel.text = "- - -"
        title = wallet.name
    }

    func walletPresenter(presenter: WalletPresenter, didRefreshTotalAmount amount: Double) {
        if amount == 0.0 {
            totalAmountLabel.text = "暂无资产"
        } else {
            totalAmountLabel.text = "≈\(presenter.currency.symbol)" + String(format: "%.4lf", amount)
        }
    }

    func walletPresenterBeganRefresh(presenter: WalletPresenter) {
        UIView.beginAnimations("refresh", context: nil)
        UIView.setAnimationDuration(0.4)
        UIView.setAnimationRepeatCount(Float(Int.max))
        UIView.setAnimationCurve(.linear)
        refreshButton.transform = refreshButton.transform.rotated(by: CGFloat(Double.pi))
        UIView.commitAnimations()
    }

    func walletPresenterEndedRefresh(presenter: WalletPresenter) {
        if tableView.refreshControl!.isRefreshing {
            tableView.refreshControl?.endRefreshing()
        }
        refreshButton.layer.removeAllAnimations()
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
            cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell_Loading") as! TokenTableViewCell
        } else if token.price == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell_NoPrice") as! TokenTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell") as! TokenTableViewCell
        }
        cell.token = presenter.tokens[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeadView
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshButton.alpha = 1 - scrollView.contentOffset.y / -125
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.refreshButton.alpha = 1.0
        self.tableView.refreshControl?.endRefreshing()
    }
}

extension WalletViewController {
}
