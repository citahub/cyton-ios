//
//  SendTransactionSwitchTokenViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/21.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol TransactionSwitchTokenViewControllerDelegate: NSObjectProtocol {
    func switchToken(switchToken: TransactionSwitchTokenViewController, didSwitchToToken tokenModel: TokenModel)
}

class TransactionSwitchTokenViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    private var tokens = [TokenModel]()
    var currentToken: TokenModel!
    weak var delegate: TransactionSwitchTokenViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tokens = AppModel.current.currentWallet!.selectedTokenList.map({ $0 })
        titleLabel.text = "Transaction.Send.txTokens".localized()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }

    @IBAction func dismiss() {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    func confirm() {
        delegate?.switchToken(switchToken: self, didSwitchToToken: currentToken)
        dismiss()
    }
}

extension TransactionSwitchTokenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TransactionSwitchTokenTableViewCell.self)) as! TransactionSwitchTokenTableViewCell
        cell.tokenLabel.text = tokens[indexPath.row].symbol
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TransactionSwitchTokenTableViewCell else { return }
        cell.selectedView.isHidden = tokens[indexPath.row].symbol != currentToken.symbol
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let oldToken = currentToken
        currentToken = tokens[indexPath.row]
        if let index = tokens.firstIndex(where: { $0.symbol == oldToken?.symbol }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView(tableView, willDisplay: tableView.cellForRow(at: indexPath)!, forRowAt: indexPath)
        }
        self.tableView(tableView, willDisplay: tableView.cellForRow(at: indexPath)!, forRowAt: indexPath)
        confirm()
    }
}

class TransactionSwitchTokenTableViewCell: UITableViewCell {
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var selectedView: UIImageView!
}
