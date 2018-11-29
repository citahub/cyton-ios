//
//  AboutUsViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/7.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import SafariServices

class AboutUsViewController: UITableViewController {
    @IBOutlet private weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings.About.AboutUs".localized()
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

    private func setVersionLabel() {
        let majorVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        versionLabel.text = "Version \(majorVersion) (\(build))"
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
