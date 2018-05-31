//
//  Sub2TableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/22.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class Sub2TableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var titlelable: UILabel!
    
    @IBOutlet weak var countLable: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let lineV = UIView.init(frame: CGRect(x: 50, y: 59, width: ScreenW - 60, height: 1))
        lineV.backgroundColor = ColorFromString(hex: "#eeeeee")
        contentView.addSubview(lineV)
        contentView.bringSubview(toFront: lineV)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
