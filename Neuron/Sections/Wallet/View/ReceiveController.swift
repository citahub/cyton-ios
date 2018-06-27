//
//  ReceiveController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import EFQRCode

class ReceiveController: BaseViewController {


    
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    var walletAddress:String?
    var walletName:String?
    var walletIcon:Data?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "收款"
        view.backgroundColor = ColorFromString(hex: "#3165f7")
        didSetUpQRCodeWithString(string: walletAddress!)
        nameLable.text = walletName! + "  " + walletAddress!
        iconImage.image = UIImage(data: walletIcon!)
    }
    
    func didSetUpQRCodeWithString(string:String) {
        let imagea = EFQRCode.generate(content: string);
        qrImageView.image = UIImage(cgImage: imagea!)
        }
    
    
    //复制地址按钮
    @IBAction func didCopyAddress(_ sender: UIButton) {
        UIPasteboard.general.string = walletAddress
        NeuLoad.showToast(text: "地址已经复制到粘贴板")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
