//
//  SearchAppController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import LYEmptyView

class SearchAppController: UITableViewController {
    @IBOutlet var textField: UITextField!
    var searchArray: [String] = []
    let browser = BrowserUrlParser()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationTitleView()
        setUpTableView()
    }

    func setUpNavigationTitleView() {
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        leftImage.image = UIImage(named: "search_left")
        leftImage.contentMode = .scaleAspectFit
        textField.leftViewMode = .always
        textField.leftView = leftImage

        let qrBtn = UIButton(type: .custom)
        qrBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        qrBtn.setImage(UIImage(named: "qrCode"), for: .normal)
        qrBtn.addTarget(self, action: #selector(didClickQRBtn), for: .touchUpInside)
        textField.rightViewMode = .always
        textField.rightView = qrBtn
    }

    func setUpTableView() {
        searchArray = UserDefaults.standard.object(forKey: "searchHistory") as? [String] ?? []
        tableView.tableFooterView = UIView()
        tableView.ly_emptyView = LYEmptyView.empty(withImageStr: "emptyData", titleStr: "您还没有搜索记录", detailStr: "")
        tableView.reloadData()
    }

    func dealWithUrl(urlStr: String) {
        if !searchArray.contains(urlStr) {
            searchArray.insert(urlStr, at: 0)
            UserDefaults.standard.set(searchArray, forKey: "searchHistory")
            tableView.reloadData()
        }
        browser.isUrlvalid(urlString: urlStr) { (_, error) in
            if error != nil {
                Toast.showToast(text: "链接无效,请重新输入")
            } else {
                let bCtrl = self.storyboard!.instantiateViewController(withIdentifier: "browserviewController") as! BrowserviewController
                bCtrl.requestUrlStr = urlStr
                self.navigationController?.pushViewController(bCtrl, animated: true)
            }
        }
    }

    // click qrButton
    @objc func didClickQRBtn() {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    // tbaleview delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ID")
        cell.textLabel?.textColor = ColorFromString(hex: "#666666")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.text = searchArray[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        browser.isUrlvalid(urlString: searchArray[indexPath.row]) { (_, error) in
            if error != nil {
                Toast.showToast(text: "链接无效,请重新输入")
            } else {
                self.performSegue(withIdentifier: "browserview", sender: indexPath.row)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "browserview" {
            let bCtrl = segue.destination as! BrowserviewController
            bCtrl.requestUrlStr = searchArray[sender as! Int]
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "browserview" {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.searchArray.remove(at: indexPath.row)
            UserDefaults.standard.set(searchArray, forKey: "searchHistory")
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}

extension SearchAppController: QRCodeControllerDelegate, UITextFieldDelegate {
    //textfield delelgate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let txt = textField.text {
            dealWithUrl(urlStr: txt)
        }
        return true
    }

    func didBackQRCodeMessage(codeResult: String) {
        if codeResult.count != 0 {
            dealWithUrl(urlStr: codeResult)
        } else {
            Toast.showToast(text: "扫描结果为空")
        }
    }

}
