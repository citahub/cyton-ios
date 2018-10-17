//
//  ContractController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ContractController: UIViewController {

    var DAppCommonModel: DAppCommonModel!
    var requestAddress: String = ""

    lazy private var valueRightView: UILabel = {
        let valueRightView = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        valueRightView.font = UIFont.systemFont(ofSize: 17)
        valueRightView.textColor = ColorFromString(hex: "#989CAA")
        valueRightView.textAlignment = .right
        return valueRightView
    }()

    lazy private var gasRightView: UILabel = {
        let gasRightView = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        gasRightView.font = UIFont.systemFont(ofSize: 17)
        gasRightView.textColor = ColorFromString(hex: "#989CAA")
        gasRightView.textAlignment = .right
        return gasRightView
    }()

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var gasTextField: UITextField!
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    @IBOutlet weak var dataTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合约调用"
        dealWithUI()

    }

    func dealWithUI() {
        tabbedButtonView.buttonTitles = ["HEX", "UTF8"]
        tabbedButtonView.delegate = self
        valueTextField.rightViewMode = .always
        valueTextField.rightView = valueRightView
        gasTextField.rightViewMode = .always
        gasTextField.rightView = gasRightView

    }

    @IBAction func didClickRejectButton(_ sender: UIButton) {

    }

    @IBAction func didClickConfirmButton(_ sender: UIButton) {

    }

}

extension ContractController: TabbedButtonsViewDelegate {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {

    }


}
