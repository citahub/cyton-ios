//
//  ButtonTagUpView.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol ButtonTagUpViewDelegate: class {
    func didDeleteSelectedButton(backDict: NSMutableDictionary)
}

class ButtonTagUpView: UIView {
    weak var delegate: ButtonTagUpViewDelegate?
    var comArr = [NSMutableDictionary]() {//包含字典的数组 字典中放的是标题和按钮tag
        didSet {
            for subView in self.subviews {
                subView.removeFromSuperview()
            }
            didSetMainViews()
        }
    }
    var titleArray: [String]! {//标题数组
        didSet {

        }
    }
    var buttonArray = [AnyObject]()//存储所有按钮的数组
    var selectArr = NSMutableArray()//存储所有按钮的数组

    //有关按钮的属性
    private var buttonBackColor: UIColor = UIColor(hex: "#ffffff")
    private var buttonTitleColor: UIColor = UIColor(hex: "#333333")
    private var hmargin: CGFloat = 10//按钮横向之间的距离
    private var vmargin: CGFloat = 10//按钮垂直之间的距离
    private var buttonHeight: CGFloat = 30//按钮的高度

    override init(frame: CGRect) {
        super.init(frame: frame)

        setBackgroundView()
    }

    func setBackgroundView() {
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "#E9EBF0").cgColor
    }

    func didSetMainViews() {

        var totalWidth: CGFloat = 0.0//到当前循环为止 所有横向按钮加起来的宽度
        var row: NSInteger = 0//第几行
        if comArr.count == 0 {

        } else {
            for i in 0...comArr.count-1 {
                let dict = comArr[i]
                let button = UIButton.init(type: .custom)
                button.layer.cornerRadius = 2.5
                button.setTitleColor(buttonTitleColor, for: .normal)
                button.backgroundColor = buttonBackColor
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                button.setTitle(dict.value(forKey: "buttonTitle") as? String, for: .normal)
                button.tag = dict.value(forKey: "buttonTag") as! Int
                button.addTarget(self, action: #selector(didClickButton(sender:)), for: .touchUpInside)
                buttonArray.append(button)

                //计算每个标题文本的宽度
                let screenSize = UIScreen.main.bounds
                let itemWidth = returnTextWidth(text: (dict.value(forKey: "buttonTitle") as? String)!, font: UIFont.systemFont(ofSize: 15), viewWidth: screenSize.width - 30).width+20
                totalWidth = totalWidth+CGFloat(itemWidth)+hmargin
                if totalWidth - hmargin > screenSize.width - 30 {//代表着要换行了 row+1 并且计算总宽度
                    totalWidth = CGFloat(itemWidth)+hmargin
                    row = row+1
                    button.frame = CGRect(x: 10, y: vmargin+CGFloat(row)*(buttonHeight+vmargin), width: CGFloat(itemWidth), height: buttonHeight)
                } else {//不换行
                    //如果不换行的话 X是总宽度减去当前按钮的宽度和横向空隙
                    button.frame = CGRect(x: totalWidth-CGFloat(itemWidth), y: CGFloat(row)*(buttonHeight+vmargin)+vmargin, width: CGFloat(itemWidth), height: buttonHeight)
                }
                self.addSubview(button)
            }
        }
    }

    //点击事件
    @objc func didClickButton(sender: UIButton) {
        comArr = comArr.filter({ (cDict) -> Bool in
            return cDict.value(forKey: "buttonTag") as! Int != sender.tag
        })
        let dict = NSMutableDictionary()
        dict.setValue(sender.currentTitle, forKey: "buttonTitle")
        dict.setValue(sender.tag, forKey: "buttonTag")
        delegate?.didDeleteSelectedButton(backDict: dict)
        sender.removeFromSuperview()
    }

    //计算文本宽度
    func returnTextWidth(text: String, font: UIFont, viewWidth: CGFloat) -> CGSize {
        return text.boundingRect(
            with: CGSize(width: viewWidth, height: CGFloat(MAXFLOAT)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
