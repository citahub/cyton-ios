//
//  TokenTableViewCell.swift
//  Cyton
//
//  Created by XiaoLu on 2018/8/31.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import web3swift

class TokenTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var symbolWidthConstraint: NSLayoutConstraint!

    var token: Token! {
        didSet {
            iconView.sd_setImage(with: URL(string: token.iconUrl), placeholderImage: UIImage(named: "eth_logo"))
            symbolLabel.text = token.symbol
            symbolWidthConstraint.constant = symbolLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: 150, height: 20), limitedToNumberOfLines: 1).size.width
            if let balance = token.balance, let balanceLabel = balanceLabel {
                balanceLabel.text = balance.toAmountText(token.decimals)
                if balance > 0 {
                    if let price = token.price {
                        let amountNumber = balance.toDecimalNumber(token.decimals).multiplying(by: NSDecimalNumber(value: price))
                        let currency = LocalCurrencyService.shared.getLocalCurrencySelect()
                        amountLabel.text = "≈\(currency.symbol)" + amountNumber.currencyFormat()
                    }
                }
            }
        }
    }

    @IBOutlet weak var ctxView: UIView!
    private var overlayView: UIView?

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            overlayView = UIView(frame: ctxView.bounds)
            overlayView?.backgroundColor = UIColor.black
            overlayView?.alpha = 0.2
            ctxView.addSubview(overlayView!)
        } else {
            overlayView?.removeFromSuperview()
        }
    }
}
