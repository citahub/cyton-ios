//
//  AboutUsTableViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/7.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class AboutUsTableViewController: UITableViewController {
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们"
        setVersionLabel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webViewController = segue.destination as! CommonWebViewController
        if segue.identifier == "serviceTerms" {
            webViewController.urlStr = "https://github.com/cryptape/neuron-ios"
        }
        if segue.identifier == "nervosNetwork" {
            webViewController.urlStr = "https://github.com/cryptape/neuron-ios"
        }
        if segue.identifier == "openSea" {
            webViewController.urlStr = "https://opensea.io/"
        }
        if segue.identifier == "sourceCode" {
            webViewController.urlStr = "https://github.com/cryptape/neuron-ios"
        }
        if segue.identifier == "infua" {
            webViewController.urlStr = "https://infura.io/"
        }
    }

    func setVersionLabel() {
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"]
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let convertedDate = dateFormatter.string(from: compileDate)
        print(convertedDate)
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
}
