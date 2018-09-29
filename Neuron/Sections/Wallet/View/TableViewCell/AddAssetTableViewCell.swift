//
//  AddAssetTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

@objc protocol AddAssetTableViewCellDelegate: NSObjectProtocol {
    @objc optional func didClickSelectCoinBtn()//点击选择币种
    @objc optional func didClickQRCodeBtn()//点击扫码
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath)
}

class AddAssetTableViewCell: UITableViewCell, UITextFieldDelegate {

    weak var delegate: AddAssetTableViewCellDelegate?

    //是否是密文
    var isSecretText: Bool = false {didSet {rightTextField.isSecureTextEntry = isSecretText}}
    var isEdit: Bool = true {didSet {rightTextField.isEnabled = isEdit}}
    var isOnlyNumberAndPoint: Bool = false

    var indexP = NSIndexPath.init()
    // 设置属性来确定不同的cell有不同的状态
    var _selectRow: NSInteger = 0
    let placeholserAttributes = [NSAttributedString.Key.foregroundColor: ColorFromString(hex: "#999999"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]

    let firstBtn = UIButton.init(type: .custom)
    let secBtn = UIButton.init(type: .custom)

    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var rightTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        //监听textfield.text
        rightTextField.addTarget(self, action: #selector(textFieldTextChanged(textField:)), for: .editingChanged)
        rightTextField.delegate = self
    }

    //重写set方法
    var placeHolderStr: String? {
        didSet {
            rightTextField.attributedPlaceholder = NSAttributedString(string: placeHolderStr!, attributes: placeholserAttributes)
        }
    }
    var selectRow: NSInteger = 0 {//传入0就是下拉样式  传入1就是点击二维码
        didSet {
            if selectRow == 0 {
                rightTextField.rightViewMode = .always
                firstBtn.setImage(UIImage.init(named: "Triangle"), for: .normal)
                firstBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 50)
                firstBtn.addTarget(self, action: #selector(didSetUpPickView), for: .touchUpInside)
                rightTextField.rightView = firstBtn
                rightTextField.tag = 3000 // 根据tag来跟别的textfield区分
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(didSetUpPickView))

                rightTextField.addGestureRecognizer(tap)
            } else if selectRow == 1 {
                rightTextField.rightViewMode = .always
                secBtn.setImage(UIImage.init(named: "qrCode"), for: .normal)
                secBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: -15)
                secBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                rightTextField.tag = 3002 // 根据tag来跟别的textfield区分
                secBtn.addTarget(self, action: #selector(didPushQRCodeView), for: .touchUpInside)
                rightTextField.rightView = secBtn
            } else {
                rightTextField.rightViewMode = .never
//                rightTextField.removeGestureRecognizer(tap)
                rightTextField.tag = 3001
            }
        }
    }

    @objc func textFieldTextChanged(textField: UITextField) {
        delegate?.didGetTextFieldTextWithIndexAndText(text: textField.text!, index: indexP)
    }

    //点击第一行按钮弹出pickerview选择币种
    @objc func didSetUpPickView() {
        print("点击第一个")
        delegate?.didClickSelectCoinBtn!()
    }
    //点击第二行按钮跳转扫描二维码界面
    @objc func didPushQRCodeView() {
        print("点击第二个")
        delegate?.didClickQRCodeBtn!()
    }

    @objc func textFieldValueChange() {

    }

    //textfidel代理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 3000 {
            return false
        } else {
            return true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isOnlyNumberAndPoint {
            guard CharacterSet(charactersIn: "0123456789.").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            if textField.text?.first == "." {
                textField.text = "0."
                return true
            }
            if (textField.text?.contains("."))! && string == "." {
                return false
            }
            return true
        } else {
            return true
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    deinit {

    }
}
