//
//  TokenTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/31.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import Web3swift

class TokenTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var symbolWidthConstraint: NSLayoutConstraint!

    var token: Token! {
        didSet {
            iconView.sd_setImage(with: URL(string: token.iconUrl ?? ""), placeholderImage: UIImage(named: "eth_logo"))
            symbolLabel.text = token.symbol
            symbolWidthConstraint.constant = symbolLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: 150, height: 20), limitedToNumberOfLines: 1).size.width
            if let balance = token.balance {
                balanceLabel.text = String(balance)
                if let price = token.price {
                    let amount = price * balance
                    let currency = LocalCurrencyService.shared.getLocalCurrencySelect()
                    amountLabel.text = "≈\(currency.symbol)" + String(format: "%.8lf", amount)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
