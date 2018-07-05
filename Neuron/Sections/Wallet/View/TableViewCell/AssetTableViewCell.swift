//
//  AssetTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SDWebImage

class AssetTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLable: UILabel!

    @IBOutlet weak var subTitleLable: UILabel!
    
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var stateBtn: UIButton!
    
    var isSelect:Bool = false{
        didSet{
            if isSelect {
                stateBtn.setImage(UIImage.init(named: "state_on"), for: .normal)
            }else{
                stateBtn.setImage(UIImage.init(named: "state_off"), for: .normal)
            }
        }
    }
    
    
    var iconUrlStr:String?{
        didSet{
            iconImage.sd_setImage(with: URL(string: iconUrlStr!), placeholderImage: UIImage.init(named: "ETH_test"), options: .retryFailed, completed: nil)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let lineV = UIView.init(frame: CGRect(x: 74, y: 74, width: ScreenW - 74, height: 1))
        lineV.backgroundColor = ColorFromString(hex: "#eeeeee")
        contentView.addSubview(lineV)
        contentView.bringSubview(toFront: lineV)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
