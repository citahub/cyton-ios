//
//  SettingsViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    let titleArray = ["本地货币", "指纹设置", "关于我们", "联系我们"]
    let imageArray = ["currency", "fingerprint_setup", "aboutus", "contactus"]

    @IBOutlet weak var sTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        sTable.delegate = self
        sTable.dataSource = self
        sTable.tableFooterView = UIView.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        let cell = tableView.dequeueReusableCell(withIdentifier: ID) ?? UITableViewCell(style: .value1, reuseIdentifier: ID)
        cell.textLabel?.textColor = ColorFromString(hex: "#2e313e")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.imageView?.image = UIImage(named: imageArray[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        switch indexPath.row {
        case 0:
            cell.detailTextLabel?.textColor = ColorFromString(hex: "#989caa")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.text = "CNY"
        case 1:
            let switchButton = UISwitch(frame: CGRect(x: 0, y: 0, width: 30, height: 15))
            switchButton.addTarget(self, action: #selector(changeFingerprintStatus(sender:)), for: .valueChanged)
            switchButton.isOn = false
            cell.accessoryView = switchButton
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let currency = CurrencyViewController()
            navigationController?.pushViewController(currency, animated: true)
        case 2:
            let aboutUs = AboutUsViewController()
            navigationController?.pushViewController(aboutUs, animated: true)
        case 3:
            let wCtrl = CommonWebViewController()
            wCtrl.urlStr = "https://www.nervos.org/contact"
            navigationController?.pushViewController(wCtrl, animated: true)
        default:
            break
        }
    }

    @objc func changeFingerprintStatus(sender: UISwitch) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
