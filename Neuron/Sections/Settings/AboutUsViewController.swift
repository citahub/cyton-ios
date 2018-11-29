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
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        let appBuild = infoDictionary["CFBundleVersion"]
        versionLabel.text = "V \(String(describing: majorVersion!)).\(String(describing: appBuild!))"
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
