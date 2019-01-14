//
//  SearchAppController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SearchAppController: UITableViewController, ErrorOverlayPresentable {
    @IBOutlet var textField: UITextField!
    var searchHistorys: [String] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.placeholder = "DApp.Search.TextFieldPlaceholder".localized()
        setUpNavigationTitleView()
    }

    func setUpNavigationTitleView() {
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        leftImage.image = UIImage(named: "search_left")
        leftImage.contentMode = .scaleAspectFit
        textField.leftViewMode = .always
        textField.leftView = leftImage

        let qrButton = UIButton(type: .custom)
        qrButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        qrButton.setImage(UIImage(named: "qr_code"), for: .normal)
        qrButton.addTarget(self, action: #selector(didClickQRButton), for: .touchUpInside)
        textField.rightViewMode = .always
        textField.rightView = qrButton
    }

    func setUpTableView() {
        searchHistorys = UserDefaults.standard.object(forKey: "searchHistory") as? [String] ?? []
        tableView.tableFooterView = UIView()
        if searchHistorys.count == 0 {
            errorOverlaycontroller.style = .blank
            showOverlay()
        } else {
            removeOverlay()
        }
        tableView.reloadData()
    }

    func dealWithUrl(urlString: String) {
        if !searchHistorys.contains(urlString) {
            searchHistorys.insert(urlString, at: 0)
            UserDefaults.standard.set(searchHistorys, forKey: "searchHistory")
            tableView.reloadData()
        }
        let browserViewController: BrowserViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
        browserViewController.requestUrlStr = urlString
        self.navigationController?.pushViewController(browserViewController, animated: true)
    }

    // click qrButton
    @objc func didClickQRButton() {
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        self.navigationController?.pushViewController(qrCodeViewController, animated: true)
    }

    // tbaleview delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistorys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "ID")
        cell.textLabel?.textColor = UIColor(hex: "#666666")
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
            if self.searchHistorys.count == 0 {
                errorOverlaycontroller.style = .blank
                showOverlay()
            }
        }

    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "DApp.Search.DeleteHistory".localized()
    }
}

extension SearchAppController: QRCodeViewControllerDelegate, UITextFieldDelegate {
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
            Toast.showToast(text: "Common.Connection.ScanEmpty".localized())
        }
    }

}
