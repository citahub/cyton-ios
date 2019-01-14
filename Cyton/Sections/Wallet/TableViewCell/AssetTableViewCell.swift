//
//  AssetTableViewCell.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SDWebImage

protocol AssetTableViewCellDelegate: class {
    func assetTableViewCell(_ assetTableViewCell: UITableViewCell, isSelected: Bool)
}

class AssetTableViewCell: UITableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet weak var statusBtn: UISwitch!
    weak var delegate: AssetTableViewCellDelegate?

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        statusBtn.isHidden = editing
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                statusBtn.isOn = true
            } else {
                statusBtn.isOn = false
            }
        }
    }

    var iconUrlStr: String? {
        didSet {
            iconImage.sd_setImage(with: URL(string: iconUrlStr!), placeholderImage: UIImage(named: "eth_test"), options: .retryFailed, completed: nil)
        }
    }

    @IBAction func selectAssetSwitch(_ sender: UISwitch) {
        delegate?.assetTableViewCell(self, isSelected: sender.isOn)
    }
}
