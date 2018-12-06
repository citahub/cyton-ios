//
//  TransactionDetailsViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/12/6.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionDetailsViewController: UITableViewController {

    var transaction: TransactionDetails!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Transaction.Details.title".localized()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TransactionDetailsViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return [(0, 1), (0, 2), (0, 3)].contains(where: { $0.0 == indexPath.section && $0.1 == indexPath.row })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
