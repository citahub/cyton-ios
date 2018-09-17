//
//  WalletTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/3.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowsView: UIView!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    override var isSelected: Bool {
        didSet{
            if isSelected {
                shadowsView.backgroundColor = ColorFromString(hex: "#6080ff")
                shadowsView.shadowColor = ColorFromString(hex: "#C8D4FF")
                nameLabel.textColor = .white
                addressLabel.textColor = .white
            } else {
                shadowsView.backgroundColor = .white
                shadowsView.shadowColor = ColorFromString(hex: "#E5E5E5")
                nameLabel.textColor = ColorFromString(hex: "#2E313E")
                addressLabel.textColor = ColorFromString(hex: "#6C7184")
            }
        }
    }
}
