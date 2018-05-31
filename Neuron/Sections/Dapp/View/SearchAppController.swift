//
//  SearchAppController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SearchAppController: BaseViewController,UITextFieldDelegate {
    
    var searchText = UITextField.init()
    
    
    //为了测试能显示出来 这边使用二维码的按钮弹出MessageSignController
    let mCtrl = MessageSignController.init(nibName: "MessageSignController", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationTitleView()
        
    }
    
    func setUpNavigationTitleView() {
        let tView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenW - 72, height: 30))
        tView.backgroundColor = UIColor.white
        tView.layer.cornerRadius = 3.0
        tView.clipsToBounds = true
        self.navigationItem.titleView = tView;

        searchText.frame = tView.frame
        searchText.leftViewMode = .always
        searchText.rightViewMode = .always
//        searchText.placeholder = "添加token名称或者合约地址"
        let placeholserAttributes = [NSAttributedStringKey.foregroundColor : ColorFromString(hex: "#999999"),NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]
        searchText.attributedPlaceholder = NSAttributedString(string: "添加token名称或者合约地址",attributes: placeholserAttributes)
        searchText.returnKeyType = UIReturnKeyType.search
        searchText.clearButtonMode = .whileEditing
        searchText.addTarget(self, action: #selector(changeTextFieldValue(text:)),for: .editingChanged)
        searchText.delegate = self;
        tView.addSubview(searchText)
        
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        leftImage.image = UIImage(named: "search_left")
        leftImage.contentMode = .scaleAspectFit
        searchText.leftView = leftImage
        
        let qrBtn = UIButton(type: .custom)
        qrBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        qrBtn.setImage(UIImage(named: "qrCode"), for: .normal)
        qrBtn.addTarget(self, action: #selector(didClickQRBtn), for: .touchUpInside)
        searchText.rightView = qrBtn
        
    }
    
    //监听textfield的内容变化
    @objc func changeTextFieldValue(text:UITextField) {
        
    }
    
    //点击扫描二维码
    @objc func didClickQRBtn(){
//        print("点击二维码")
//        let qrCtrl = QRCodeController()
//        self.navigationController?.pushViewController(qrCtrl, animated: true)
        UIApplication.shared.keyWindow?.addSubview(mCtrl.view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let cCtrl = ContractController.init(nibName: "ContractController", bundle: nil)
        navigationController?.pushViewController(cCtrl, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
