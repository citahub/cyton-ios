

//
//  SubController4TableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SubController4TableViewCell: UITableViewCell {

    @IBOutlet weak var appNameLable: UILabel!
    @IBOutlet weak var versionLable: UILabel!
    
    var compileDate:Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"]
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let convertedDate = dateFormatter.string(from: compileDate)
        print(convertedDate)
        appNameLable.text = appDisplayName as? String
        versionLable.text = "V \(String(describing: majorVersion!))" + ".\(convertedDate)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
