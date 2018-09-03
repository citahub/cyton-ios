//
//  WalletTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/3.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLable: UILabel!
    @IBOutlet var addressLable: UILabel!
    @IBOutlet var statusImageView: UIImageView!
    var selectStatus: Bool = false {
        didSet {
            if selectStatus {
                statusImageView.isHidden = false
            } else {
                statusImageView.isHidden = true
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
