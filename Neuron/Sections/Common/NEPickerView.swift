//
//  NEPickerView.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol NEPickerViewDelegate: class {
    func callBackDictionnary(dict: [String: String])
}

class NEPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    var dataArray: [[String: String]] = []

    weak var delegate: NEPickerViewDelegate?
    var finalDict: [String: String] = [String: String]()

    var selectDict: [String: String] = [String: String]()

    private let bottomView = UIView.init()
    private let pickerV = UIPickerView.init()
    private let sureBtn = UIButton.init(type: .custom)
    private let cancleBtn = UIButton.init(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    override func layoutSubviews() {
        bottomView.frame = CGRect(x: 0, y: ScreenSize.height - 200, width: ScreenSize.height, height: 200)
        bottomView.backgroundColor = .white
        self.addSubview(bottomView)
        sureBtn.frame = CGRect(x: ScreenSize.width-(15 + 48), y: 0, width: 48, height: 40)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sureBtn.setTitleColor(ColorFromString(hex: "#4eb9f8"), for: .normal)
        sureBtn.addTarget(self, action: #selector(didClickSureBtn(sender:)), for: .touchUpInside)
        bottomView.addSubview(sureBtn)

        cancleBtn.frame = CGRect(x: 15, y: 0, width: 48, height: 40)
        cancleBtn.setTitle("取消", for: .normal)
        cancleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancleBtn.setTitleColor(ColorFromString(hex: "#4eb9f8"), for: .normal)
        cancleBtn.addTarget(self, action: #selector(didClickCancleButton(sender:)), for: .touchUpInside)
        bottomView.addSubview(cancleBtn)

        pickerV.frame = CGRect(x: 0, y: 40, width: ScreenSize.width, height: 160)
        pickerV.backgroundColor = ColorFromString(hex: "#ededed")
        pickerV.delegate = self
        pickerV.dataSource = self
        bottomView.addSubview(pickerV)
        if selectDict.count != 0 {
            pickerV.selectRow(dataArray.index(of: selectDict)!, inComponent: 0, animated: true)
            pickerV.reloadAllComponents()
            finalDict = selectDict
        }
    }

    //点击完成
    @objc func didClickSureBtn(sender: UIButton) {
        delegate?.callBackDictionnary(dict: finalDict)
        self.removeFromSuperview()

    }
    //click cancle
    @objc func didClickCancleButton(sender: UIButton) {
        self.removeFromSuperview()
    }

    //pickerview代理
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var dict = dataArray[row]
        if dict["id"] == "0"{
            dict["name"] = "m/44'/60'/0'/0/0 metamask/jaxx兼容(ETH)"
        } else if dict["id"] == "1"{
            dict["name"] = "m/44'/60'/0'/0 Ledger(ETH)"
        } else if dict["id"] == "2"{
            dict["name"] = "m/44'/60'/1'/0/0 自定义路径"
        }

        let name =  dict["name"]
        return name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        finalDict = dataArray[row]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
