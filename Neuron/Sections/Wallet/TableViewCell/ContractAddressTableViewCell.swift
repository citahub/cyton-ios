//
//  ContractAddressTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class ContractAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var contractAddressLabel: UILabel!
    @IBOutlet weak var contractAddressTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        contractAddressLabel.text = "Assets.AddAssets.ContractAddress".localized()
        contractAddressTextField.placeholder = "Assets.AddAssets.ContractAddressPlaceHolder".localized()
    }
}
