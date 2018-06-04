//
//  SureMnemonicViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SureMnemonicViewController: BaseViewController,ButtonTagViewDelegate,ButtonTagUpViewDelegate {

    var titleArr:Array<String> = ["aaa","aaa","dress","mini skirt","mirror","thirsty","classmate"]
    
    
    private var showView : ButtonTagView! = nil
    private var selectView : ButtonTagUpView! = nil
    let sureButton = UIButton.init(type: .custom)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "确认助记词"
        didDrawSubViews()
        
    }
    
    func didDrawSubViews() {
        
        selectView = ButtonTagUpView.init(frame: CGRect(x: 15, y: 15+35, width: ScreenW - 30, height: 200))
        selectView.backgroundColor = ColorFromString(hex: "#f5f5f5")
        selectView.delegate = self
        view.addSubview(selectView)
        
        showView = ButtonTagView.init(frame: CGRect(x: 15, y: 15+35 + 100 , width: ScreenW - 30, height: 200))
        showView.titleArray = titleArr
        showView.delegate = self
        showView.backgroundColor = .white
        view.addSubview(showView)
        
        sureButton.frame = CGRect(x: 15, y: showView.frame.origin.y + showView.frame.size.height + 20, width: ScreenW - 30, height: 44)
        sureButton.backgroundColor = ColorFromString(hex: "#f2f2f2")
        sureButton.setTitleColor(ColorFromString(hex: "#999999"), for: .normal)
        sureButton.setTitle("完成备份", for: .normal)
        sureButton.layer.cornerRadius = 5
        view.addSubview(sureButton)
        
    }
    
    //选择按钮的时候返回的选择的数组
    func callBackSelectButtonArray(array: Array<NSMutableDictionary>) {
        selectView.comArr = array
        
        for name in array {
            print(name)
            
        }
    }

    
    //点击删除按钮的时候 下方按钮改变选中状态
    func didDeleteSelectedButton(backDict: NSMutableDictionary) {
        showView.deleteDict = backDict
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
