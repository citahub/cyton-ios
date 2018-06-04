//
//  SQButtonTagView.swift
//  SQButtonTagViewSwift
//
//  Created by yangsq on 2017/9/27.
//  Copyright © 2017年 yangsq. All rights reserved.
//

import UIKit

class SQButtonTagView: UIView {

    var tagTexts:Array<String> = []
    var eachNum:Int = 0
    var maxSelectNum:Int? = 100//默认最多可以选的
    typealias SelectBlock = (NSArray) -> Void
    var selectBlock:SelectBlock?
    
    
    private var totalTagsNum:Int = 0
    private var hmargin:CGFloat = 0.0
    private var vmargin:CGFloat = 0.0
    private var tagHeight:CGFloat = 0.0
    private var viewWidth:CGFloat = 0.0
    private var buttonTags = NSMutableArray()
    private var tagTextFont:UIFont?
    private var tagTextColor:UIColor?
    private var selectedTagTextColor:UIColor?
    private var selectedBackgroundColor:UIColor?
    private var selectArray = NSMutableArray()
    
    
    init(totalTagNum:Int, viewWidth:CGFloat, eachNum:Int,hmargin:CGFloat, vmargin:CGFloat, tagheight:CGFloat,tagTextFont:UIFont, tagTextColor:UIColor, selectedTagTextColor:UIColor, selectedBackgroundColor:UIColor){
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.totalTagsNum = totalTagNum
        self.viewWidth = viewWidth
        self.eachNum = eachNum
        self.hmargin = hmargin
        self.vmargin = vmargin
        self.tagHeight = tagheight
        self.tagTextFont = tagTextFont
        self.tagTextColor = tagTextColor
        self.selectedTagTextColor = selectedTagTextColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.setView()
    }
    
    
    class func returnViewHeight(tagTexts:Array<Any>, viewWidth:CGFloat, eachNum:NSInteger, hmargin:CGFloat, vmargin:CGFloat, tagHeight:CGFloat,tagTextFont:UIFont) -> CGFloat{
        
        var height:CGFloat = 0.0
        
        if eachNum>0 {
            if tagTexts.count>0 {
                var a = tagTexts.count/eachNum  as NSInteger
                let b = tagTexts.count%eachNum as NSInteger
                if b>0&&a>=0 {
                    a+=1
                }
                height = CGFloat(a) * tagHeight + CGFloat(a-1)*vmargin
            }
        }else{
            var totalWidth:CGFloat = 0.0
            var  row:Int = 0
            for  i in 0 ..< tagTexts.count-1 {
                let textStr = tagTexts[i] as! NSString
                let itemWidth = self.returnTextWidth(text: textStr, font: tagTextFont, viewWidth: viewWidth).width+20
                
                totalWidth = totalWidth+CGFloat(itemWidth)+hmargin
                if totalWidth - hmargin > viewWidth {
                    totalWidth = itemWidth+hmargin
                    row = row+1
                }
                height = tagHeight*CGFloat((row+1))+CGFloat(row)*vmargin
            }
        }
        return CGFloat(Float(height + 24))
    }
    
    
    
    func setView(){
        
        
        for i in 0...self.totalTagsNum-1 {
            
            let button = UIButton(type: .custom)
            button.layer.cornerRadius = 2.5
            button.layer.borderColor = self.tagTextColor?.cgColor
            button.layer.borderWidth = 0.5
            button.setTitleColor(self.tagTextColor, for: .normal)
            button.titleLabel?.font = self.tagTextFont
            self.addSubview(button)
            self.buttonTags.add(button)
            button.tag = 101 + i
            button.addTarget(self, action: #selector(buttonAction(button:)), for: .touchUpInside)
            
        }
        
    }
    
    
    //MARK: 点击
    
    @objc func buttonAction(button:UIButton) {
        
        let tag = button.tag-101
        if (self.selectArray.contains(tag)) {
            self.selectArray.remove(tag)
        }else{
            if self.selectArray.count==self.maxSelectNum {
                
            }else{
                self.selectArray.add(tag)
            }
        }
        if (self.selectBlock != nil) {
            self.selectBlock!(self.selectArray)
        }
        self.refreshView()
    }
    

    func refreshView(){
        
        for button in self.buttonTags{
            let btn = button as! UIButton
            if self.selectArray .contains(btn.tag-101) {
                btn.backgroundColor = self.selectedBackgroundColor
                btn.setTitleColor(self.selectedTagTextColor, for: .normal)
                btn.layer.borderColor = self.selectedBackgroundColor?.cgColor
            }else{
                btn.backgroundColor = nil
                btn.setTitleColor(self.tagTextColor, for: .normal)
                btn.layer.borderColor = self.tagTextColor?.cgColor
            }
        }
        
    }
    
    
   class func  returnTextWidth(text:NSString,font:UIFont,viewWidth:CGFloat) -> CGSize {
        var attr = Dictionary<NSAttributedStringKey,AnyObject>()
        attr[NSAttributedStringKey.font] = font
        let textSize = text.boundingRect(with: CGSize(width:viewWidth,height:CGFloat(MAXFLOAT)), options:[.usesLineFragmentOrigin,.usesFontLeading], attributes: attr, context: nil).size
        return textSize
    }
    
    
    func setTagTexts(tagTexts:Array<Any>) {
        self.tagTexts = tagTexts as! Array<String>
        
        if self.eachNum>0 {
            let width = (self.viewWidth-CGFloat(self.eachNum-1)*self.hmargin)/CGFloat(self.eachNum)
            
            for i in 0...self.buttonTags.count-1 {
                let button = self.buttonTags[i] as! UIButton
                if i<tagTexts.count {
                    button.setTitle(tagTexts[i] as? String, for: .normal)
                    let a = i/self.eachNum
                    let b = i%self.eachNum
                    button.frame = CGRect(x: CGFloat(b)*(width+self.hmargin), y: CGFloat(a)*(self.tagHeight+self.vmargin), width: width, height: self.tagHeight)
                    button.isHidden = false
                }else{
                    button.isHidden = true
                }
            }
        
        }else{
            
            var totalWidth:CGFloat = 0.0
            var row:NSInteger = 0
            
            for i in 0...self.buttonTags.count-1 {
                let button = self.buttonTags[i] as! UIButton

                if i<tagTexts.count {
                    let textStr = tagTexts[i] as! NSString
                    let itemWidth = SQButtonTagView.returnTextWidth(text: textStr, font: tagTextFont!, viewWidth: viewWidth).width+20
                    totalWidth = totalWidth+CGFloat(itemWidth)+hmargin
                    if totalWidth - hmargin > viewWidth {
                        totalWidth = itemWidth+hmargin
                        row = row+1
                       button.frame = CGRect(x: 10, y: CGFloat(row)*(self.tagHeight+self.vmargin)+self.vmargin, width: itemWidth, height: self.tagHeight)
                    }else{
                         button.frame = CGRect(x: totalWidth-itemWidth, y: CGFloat(row)*(self.tagHeight+self.vmargin)+self.vmargin, width: itemWidth, height: self.tagHeight)
                    }
                    button.isHidden = false
                    button.setTitle((tagTexts[i] as! String), for: .normal)
                }else{
                    button.isHidden = true
                }
            }
        }
    }
    
    func selectBlockAction(block:@escaping SelectBlock) {
        self.selectBlock = block;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
