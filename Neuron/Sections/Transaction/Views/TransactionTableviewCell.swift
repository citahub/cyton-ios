//
//  Sub3TableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TransactionTableviewCell: UITableViewCell {

    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let walletModel = AppModel.current.currentWallet
        iconImageV.image = UIImage(data: (walletModel?.iconData)!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
