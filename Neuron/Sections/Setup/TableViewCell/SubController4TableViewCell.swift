

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
    override func awakeFromNib() {
        super.awakeFromNib()
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"]
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
//        let minorVersion = infoDictionary["CFBundleVersion"]
        appNameLable.text = appDisplayName as? String
        versionLable.text = "V \(String(describing: majorVersion!))"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
