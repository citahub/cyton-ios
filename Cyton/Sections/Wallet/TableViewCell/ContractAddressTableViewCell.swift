//
//  ContractAddressTableViewCell.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol ContractAddressTableViewCellDelegate: class {
    func textFieldInput(text: String)
}

class ContractAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var contractAddressLabel: UILabel!
    @IBOutlet weak var contractAddressTextField: UITextField!
    weak var delegate: ContractAddressTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        contractAddressLabel.text = "Assets.AddAssets.ContractAddress".localized()
        contractAddressTextField.placeholder = "Assets.AddAssets.ContractAddressPlaceHolder".localized()
        contractAddressTextField.addTarget(self, action: #selector(textFieldTextChanged(textField:)), for: .editingChanged)
    }

    @objc func textFieldTextChanged(textField: UITextField) {
        delegate?.textFieldInput(text: textField.text!)
    }
}
