//
//  SearchAppController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import LYEmptyView

class SearchAppController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, QRCodeControllerDelegate {

    var searchText = UITextField.init()
    var searchArray: [String] = []

    let browser = BrowserUrlParser()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationTitleView()
        setUpTableView()
    }

    @IBOutlet weak var sTable: UITableView!
    func setUpNavigationTitleView() {
        let tView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenW - 72, height: 30))
        tView.backgroundColor = UIColor.white
        tView.layer.cornerRadius = 3.0
        tView.clipsToBounds = true
        self.navigationItem.titleView = tView

        searchText.frame = tView.frame
        searchText.leftViewMode = .always
        searchText.rightViewMode = .always
        let placeholserAttributes = [NSAttributedStringKey.foregroundColor: ColorFromString(hex: "#999999"), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        searchText.attributedPlaceholder = NSAttributedString(string: "添加token名称或者合约地址", attributes: placeholserAttributes)
        searchText.returnKeyType = UIReturnKeyType.search
        searchText.clearButtonMode = .whileEditing
        searchText.addTarget(self, action: #selector(changeTextFieldValue(text:)), for: .editingChanged)
        searchText.delegate = self
        tView.addSubview(searchText)

        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        leftImage.image = UIImage(named: "search_left")
        leftImage.contentMode = .scaleAspectFit
        searchText.leftView = leftImage

        let qrBtn = UIButton(type: .custom)
        qrBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        qrBtn.setImage(UIImage(named: "qrCode"), for: .normal)
        qrBtn.addTarget(self, action: #selector(didClickQRBtn), for: .touchUpInside)
        searchText.rightView = qrBtn
    }

    func setUpTableView() {
        searchArray = UserDefaults.standard.object(forKey: "searchHistory") as? [String] ?? []
        print(searchArray)
        sTable.delegate = self
        sTable.dataSource = self
        sTable.tableFooterView = UIView.init()
//        sTable.setEditing(true, animated: false)
        sTable.ly_emptyView = LYEmptyView.empty(withImageStr: "emptyData", titleStr: "您还没有搜索记录", detailStr: "")
        sTable.reloadData()
    }

    // monitor textfield value
    @objc func changeTextFieldValue(text: UITextField) {

    }

    func dealWithUrl(urlStr: String) {
        if !searchArray.contains(urlStr) {
            searchArray.append(urlStr)
            searchArray.reverse()
            UserDefaults.standard.set(searchArray, forKey: "searchHistory")
        }
        browser.isUrlvalid(urlStr: urlStr) { (_, error) in
            if error != nil {
                NeuLoad.showToast(text: "链接无效,请重新输入")
            } else {
                let bCtrl = BrowserviewController()
                bCtrl.requestUrlStr = urlStr
                self.navigationController?.pushViewController(bCtrl, animated: true)
            }
        }
    }

    //textfield delelgate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if let txt = textField.text {
            dealWithUrl(urlStr: txt)
        }
        return true
    }

    // click qrButton
    @objc func didClickQRBtn() {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    func didBackQRCodeMessage(codeResult: String) {
        if codeResult.count != 0 {
            dealWithUrl(urlStr: codeResult)
        } else {
            NeuLoad.showToast(text: "扫描结果为空")
        }
    }

    // tbaleview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ID")
        cell.textLabel?.textColor = ColorFromString(hex: "#666666")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.text = searchArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        browser.isUrlvalid(urlStr: searchArray[indexPath.row]) { (_, error) in
            if error != nil {
                NeuLoad.showToast(text: "链接无效,请重新输入")
            } else {
                let bCtrl = BrowserviewController()
                bCtrl.requestUrlStr = self.searchArray[indexPath.row]
                self.navigationController?.pushViewController(bCtrl, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.searchArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
