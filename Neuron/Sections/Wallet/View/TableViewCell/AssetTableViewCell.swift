//
//  AssetTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SDWebImage

class AssetTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusBtn: UISwitch!

    var isSelect: Bool = false {
        didSet {
            if isSelect {
                statusBtn.isOn = true
            } else {
                statusBtn.isOn = false
            }
        }
    }

    var iconUrlStr: String? {
        didSet {
            iconImage.sd_setImage(with: URL(string: iconUrlStr!), placeholderImage: UIImage.init(named: "ETH_test"), options: .retryFailed, completed: nil)
        }
    }
}
