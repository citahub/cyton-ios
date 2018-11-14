//
//  AboutUsTableViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/7.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import SafariServices

class AboutUsTableViewController: UITableViewController {
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们"
        setVersionLabel()
    }

    private var projectGithubUrls = [
        "https://github.com/cryptape/neuron-ios",
        "https://docs.nervos.org/neuron-android/#/product-agreement"
    ]

    private var secondSectionUrls = [
        "https://www.nervos.org/",
        "https://infura.io/",
        "https://opensea.io/",
        "https://peckshield.com/",
        "https://github.com/cryptape/cita"
    ]

    func setVersionLabel() {
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"]
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let convertedDate = dateFormatter.string(from: compileDate)
        versionLabel.text = appDisplayName as? String
        versionLabel.text = "V \(String(describing: majorVersion!))" + ".\(convertedDate)"
    }

    var compileDate: Date {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date { return infoDate }
        return Date()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var urlString: String?
        if indexPath.section == 1 {
            urlString = projectGithubUrls[indexPath.row]
        } else if indexPath.section == 2 {
            urlString = secondSectionUrls[indexPath.row]
        }
        if let urlString = urlString {
            let safariController = SFSafariViewController(url: URL(string: urlString)!)
            self.present(safariController, animated: true, completion: nil)
        }
    }
}
