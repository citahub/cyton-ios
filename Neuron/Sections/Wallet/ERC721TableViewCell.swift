//
//  ERC721TableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/1.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class ERC721TableViewCell: UITableViewCell {
    @IBOutlet var ERC721Image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var network: UILabel!
    @IBOutlet var number: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
