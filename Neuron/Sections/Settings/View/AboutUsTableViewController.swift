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
        let urlString: String = URLs[segue.identifier ?? ""] ?? URLs.first!.value
        let webViewController = segue.destination as! CommonWebViewController
        webViewController.url = URL(string: urlString)!
    }

    private var URLs = [
        "serviceTerms": "https://github.com/cryptape/neuron-ios",
        "nervosNetwork": "https://github.com/cryptape/neuron-ios",
        "openSea": "https://opensea.io/",
        "sourceCode": "https://github.com/cryptape/neuron-ios",
        "infua": "https://infura.io/",
        "PeckShield": "https://peckshield.com/",
        "Cita": "https://github.com/cryptape/cita"
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
}
