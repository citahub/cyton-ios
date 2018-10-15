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
    var searchHistorys: [String] = []

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

        let qrButton = UIButton(type: .custom)
        qrButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        qrButton.setImage(UIImage(named: "qrCode"), for: .normal)
        qrButton.addTarget(self, action: #selector(didClickQRButton), for: .touchUpInside)
        textField.rightViewMode = .always
        textField.rightView = qrButton
    }

    func setUpTableView() {
        searchHistorys = UserDefaults.standard.object(forKey: "searchHistory") as? [String] ?? []
        tableView.tableFooterView = UIView()
        tableView.ly_emptyView = LYEmptyView.empty(withImageStr: "emptyData", titleStr: "您还没有搜索记录", detailStr: "")
        tableView.reloadData()
    }

    func dealWithUrl(urlString: String) {
        if !searchHistorys.contains(urlString) {
            searchHistorys.insert(urlString, at: 0)
            UserDefaults.standard.set(searchHistorys, forKey: "searchHistory")
            tableView.reloadData()
        }
        let browserViewController = self.storyboard!.instantiateViewController(withIdentifier: "browserViewController") as! BrowserViewController
        browserViewController.requestUrlStr = urlString
        self.navigationController?.pushViewController(browserViewController, animated: true)
    }

    // click qrButton
    @objc func didClickQRButton() {
        let qRCodeController = QRCodeController()
        qRCodeController.delegate = self
        self.navigationController?.pushViewController(qRCodeController, animated: true)
    }

    // tbaleview delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistorys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ID")
        cell.textLabel?.textColor = ColorFromString(hex: "#666666")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.text = searchHistorys[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "browserView", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "browserView" {
            let browserViewController = segue.destination as! BrowserViewController
            browserViewController.requestUrlStr = searchHistorys[sender as! Int]
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "browserView" {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.searchHistorys.remove(at: indexPath.row)
            UserDefaults.standard.set(searchHistorys, forKey: "searchHistory")
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
            dealWithUrl(urlString: txt)
        }
        return true
    }

    func didBackQRCodeMessage(codeResult: String) {
        if codeResult.count != 0 {
            dealWithUrl(urlString: codeResult)
        } else {
            Toast.showToast(text: "扫描结果为空")
        }
    }

}
