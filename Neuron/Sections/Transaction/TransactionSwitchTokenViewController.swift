//
//  SendTransactionSwitchTokenViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/21.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol TransactionSwitchTokenViewControllerDelegate: NSObjectProtocol {
    func switchToken(switchToken: TransactionSwitchTokenViewController, didSwitchToToken token: TokenModel)
}

class TransactionSwitchTokenViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var tokens = [TokenModel]()
    var currentToken: TokenModel!
    weak var delegate: TransactionSwitchTokenViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tokens += WalletRealmTool.getCurrentAppModel().nativeTokenList
        tokens += WalletRealmTool.getCurrentAppModel().currentWallet!.selectTokenList
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

    @IBAction func confirm() {
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
        if tokens[indexPath.row].symbol == currentToken.symbol {
            cell.tokenLabel.textColor = UIColor(red: 72/255.0, green: 109/255.0, blue: 255/255.0, alpha: 1.0)
        } else {
            cell.tokenLabel.textColor = UIColor(red: 36/255.0, green: 43/255.0, blue: 67/255.0, alpha: 1.0)
        }
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
    }
}

class TransactionSwitchTokenTableViewCell: UITableViewCell {
    @IBOutlet weak var tokenLabel: UILabel!
}
