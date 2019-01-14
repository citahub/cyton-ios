//
//  ButtonTagView.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol ButtonTagViewDelegate: class {
    func callBackSelectButtonArray(array: [NSMutableDictionary])

}

class ButtonTagView: UIView {

    weak var delegate: ButtonTagViewDelegate?

    var titleArray: [String]! {//标题数组
        didSet {
            didSetMainViews()
        }
    }

    var buttonArray = [AnyObject]()//存储所有按钮的数组
    var selectArr = [UIButton]()//存储选中的按钮

    var deleteDict = NSMutableDictionary() {
        didSet {
            selectArr = selectArr.filter({ (item) -> Bool in
                return deleteDict.value(forKey: "buttonTag") as! Int != item.tag
            })
            refreshView()
        }
    }

    //有关按钮的属性
    private var buttonBackColor: UIColor = UIColor(hex: "#f7f7f7")
    private var buttonTitleColor: UIColor = UIColor(hex: "#333333")

    private var hmargin: CGFloat = 10//按钮横向之间的距离
    private var vmargin: CGFloat = 10//按钮垂直之间的距离
    private var buttonHeight: CGFloat = 30//按钮的高度

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func didSetMainViews() {
        var totalWidth: CGFloat = 0.0//到当前循环为止 所有横向按钮加起来的宽度
        var row: NSInteger = 0//第几行

        for i in 0...titleArray.count-1 {
            let button = UIButton.init(type: .custom)
            button.layer.cornerRadius = 2.5
            button.setTitleColor(buttonTitleColor, for: .normal)
            button.backgroundColor = buttonBackColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitle(titleArray[i], for: .normal)
            button.addTarget(self, action: #selector(didClickButton(sender:)), for: .touchUpInside)
            button.tag = 2000+i
            buttonArray.append(button)

            //计算每个标题文本的宽度
            let screenSize = UIScreen.main.bounds
            let itemWidth = returnTextWidth(text: titleArray[i], font: UIFont.systemFont(ofSize: 15), viewWidth: screenSize.width - 30).width+20
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

    //点击事件
    @objc func didClickButton(sender: UIButton) {

        if selectArr.contains(sender) {
            selectArr = selectArr.filter { (item) -> Bool in
                return item.tag != sender.tag
            }
        } else {
            selectArr.append(sender)
        }
        var nameArray: [String] = [""]
        nameArray.removeAll()

        var backArray = [NSMutableDictionary]()//新建一个字典数组
        for button in selectArr {
            nameArray.append(button.currentTitle!)
            let dict = NSMutableDictionary()
            dict.setValue(button.currentTitle!, forKey: "buttonTitle")
            dict.setValue(button.tag, forKey: "buttonTag")
            backArray.append(dict)
        }

        delegate?.callBackSelectButtonArray(array: backArray)
        refreshView()
    }

    func refreshView() {
        for button in self.buttonArray {
            let btn = button as! UIButton
            if selectArr.contains(btn) {
                btn.backgroundColor = UIColor(hex: "#2e4af2")
                btn.setTitleColor(.white, for: .normal)
            } else {
                btn.backgroundColor = buttonBackColor
                btn.setTitleColor(buttonTitleColor, for: .normal)
            }
        }
    }

    //计算文本宽度
    func  returnTextWidth(text: String, font: UIFont, viewWidth: CGFloat) -> CGSize {
        var attr = [NSAttributedString.Key: AnyObject]()
        attr[NSAttributedString.Key.font] = font
        return text.boundingRect(
            with: CGSize(width: viewWidth, height: CGFloat(MAXFLOAT)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attr,
            context: nil
         ).size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
