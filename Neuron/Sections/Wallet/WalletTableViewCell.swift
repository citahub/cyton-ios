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
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
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
}
