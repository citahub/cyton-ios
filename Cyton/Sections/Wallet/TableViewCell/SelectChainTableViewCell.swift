//
//  SelectChainTableViewCell.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class SelectChainTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.text = "Assets.AddAssets.BlockChainNetwork".localized()
    }
}
