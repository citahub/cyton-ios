//
//  TxSummaryPageItem.swift
//  Cyton
//
//  Created by James Chen on 2018/11/19.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

// Showing transaction summary before sending out.
class TxSummaryPageItem: BLTNPageItem {
    private let summaryView = SendTransactionSummaryView.loadFromNib()

    static func create() -> TxSummaryPageItem {
        let item = TxSummaryPageItem(title: "Transaction.Send.txInfo".localized())
        item.appearance = PageItemAppearance.default
        item.actionButtonTitle = "Transaction.Send.confirmSendTx".localized()
        return item
    }

    func update(_ param: TransactionParamBuilder) {
        summaryView.amountLabel.text = param.value.toAmountText(param.decimals)

        let range = NSRange(location: summaryView.amountLabel.text!.lengthOfBytes(using: .utf8), length: param.symbol.lengthOfBytes(using: .utf8))
        summaryView.amountLabel.text! += param.symbol
        let attributedText = NSMutableAttributedString(attributedString: summaryView.amountLabel.attributedText!)
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], range: range)
        summaryView.amountLabel.attributedText = attributedText

        summaryView.fromLabel.text = param.from
        summaryView.toLabel.text = param.to
        summaryView.txFeeLabel.text = "\(param.txFeeText) \(param.nativeCoinSymbol)"
    }

    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        return [summaryView]
    }
}

class SendTransactionSummaryView: UIView, NibLoadable {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var txFeeLabel: UILabel!
    @IBOutlet private weak var fromAddressTitleLabel: UILabel!
    @IBOutlet private weak var toAddressTitleLabel: UILabel!
    @IBOutlet private weak var txFeeTitleLabel: UILabel!

    override func didMoveToWindow() {
        super.didMoveToWindow()
        fromAddressTitleLabel.text = "Transaction.Details.paymentAddress".localized()
        toAddressTitleLabel.text = "Transaction.Details.receiptAddress".localized()
        txFeeTitleLabel.text = "Transaction.Details.gasFee".localized()
    }
}
