//
//  TradeTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TradeTableViewCell: UITableViewCell {
    var titleStr: String? {
        didSet {
            titleLabel.text = titleStr
        }
    }
    var subTitleStr: String? {
        didSet {
            subButton.setTitle(subTitleStr, for: .normal)
        }
    }
    var ethOrNervos: String = ""
    var selectIndex: NSIndexPath? {
        didSet {
            if ethOrNervos == "ETH" {
                if selectIndex?.row == 1 || selectIndex?.row == 2 || selectIndex?.row == 5 {
                    subButton.setImage(UIImage.init(named: "复制"), for: .normal)
                    subButton.setTitleColor(ColorFromString(hex: "#2e4af2"), for: .normal)
                } else {
                    subButton.isEnabled = false
                }
            } else if ethOrNervos == "Nervos" {
                if selectIndex?.row == 1 || selectIndex?.row == 2 || selectIndex?.row == 4 {
                    subButton.setImage(UIImage.init(named: "复制"), for: .normal)
                    subButton.setTitleColor(ColorFromString(hex: "#2e4af2"), for: .normal)
                } else {
                    subButton.isEnabled = false
                }
            }
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func didClickSubButton(_ sender: UIButton) {
        UIPasteboard.general.string = subTitleStr
        NeuLoad.showToast(text: "复制成功")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
