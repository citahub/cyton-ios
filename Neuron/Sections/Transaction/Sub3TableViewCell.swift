//
//  Sub3TableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class Sub3TableViewCell: UITableViewCell {

    var statusType:String? {
        didSet{
            //根据状态来判断stateImageV加载不同的图片
            print(statusType!)
        }
    }
    
    
    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var limitLable: UILabel!
    @IBOutlet weak var dataLable: UILabel!
    @IBOutlet weak var exchangeLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet
        iconImageV.image = UIImage(data: (walletModel?.iconData)!)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    
    
}
