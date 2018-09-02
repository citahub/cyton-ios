//
//  TokenTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/31.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {
    @IBOutlet var tokenImage: UIImageView!
    @IBOutlet var token: UILabel!
    @IBOutlet var balance: UILabel!
    @IBOutlet var currency: UILabel!
    @IBOutlet var network: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
