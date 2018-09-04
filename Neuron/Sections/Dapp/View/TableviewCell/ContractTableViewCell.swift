//
//  ContractTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ContractTableViewCell: UITableViewCell, UITextFieldDelegate {

    var headLabStr: String? {
        didSet {
            headLabel.text = headLabStr
        }
    }

    var textFieldStr: String? {
        didSet {
            textField.text = textFieldStr
        }
    }

    var unitLabStr: String? {
        didSet {
            if unitLabStr?.count != 0 {
                textField.rightViewMode = .always
                rightView.text = unitLabStr
            } else {
                textField.rightViewMode = .never
            }
        }
    }

    let rightView = UILabel.init(frame: CGRect(x: 0, y: 0, width: 40, height: 44))

    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        rightView.textColor = ColorFromString(hex: "#b7b7b7")
        rightView.font = UIFont.systemFont(ofSize: 17)
        textField.rightView = rightView
    }

    //textField代理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
