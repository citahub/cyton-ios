//
//  ConTractLastTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ConTractLastTableViewCell: UITableViewCell {
    
    //应该是传入两个字符串 点哪个按钮就显示什么内容
    var hexStr:String?{
        didSet{
            textView.text = hexStr
        }
    }
    var UTF8Str = ""
    
    
    
    let lineV = UIView.init()
    @IBOutlet weak var headLable: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineV.frame = CGRect(x: 0, y: 39, width: ScreenW * 0.459, height: 5)
        lineV.backgroundColor = ColorFromString(hex: "#fe8227")
        bView.addSubview(lineV)
        bView.layer.borderColor = ColorFromString(hex: "#cccccc").toCGColor()
        leftBtn.layer.borderColor = ColorFromString(hex: "#cccccc").toCGColor()
        rightBtn.layer.borderColor = ColorFromString(hex: "#cccccc").toCGColor()
        textView.isEditable = false
    }
    
    
    @IBAction func didClickHEXButton(_ sender: UIButton) {
        lineV.frame = CGRect(x: 0, y: 39, width: ScreenW * 0.459, height: 5)
        textView.text = hexStr
    }
    
    @IBAction func didClickUTF8Button(_ sender: UIButton) {
        lineV.frame = CGRect(x: ScreenW * 0.459, y: 39, width: ScreenW * 0.459, height: 5)
        textView.text = UTF8Str
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
