//
//  NeuronProgressView.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

//    # 这个代理协议是为了在进度条改变的时候  让其代理执行方法  例如音频根据改变的进度去  相应的调整到对应的位置播放
protocol NeuronProgressViewDelegate
{
    func NProgressView(neuronProgressView: UIProgressView, changeProgress currenProgress:Float)
    
}

class NeuronProgressView: UIView {
    
    let progressV = UIProgressView.init()
    
    // 进度条上的滑块
    let sliderView: UIView = UIView.init()
    // 代理
    var delegate:NeuronProgressViewDelegate?
    
    // 代码初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)

        // 设置一下  滑块的大小 位置 颜色 等属性
        sliderView.backgroundColor = ColorFromString(hex: "#2e4af2")
        sliderView.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        sliderView.layer.cornerRadius = 10
        sliderView.clipsToBounds = true
        // 让小滑块的中心点 在进度的端点位置
        sliderView.center = CGPoint(x: CGFloat(progressV.progress) * progressV.bounds.size.width, y: progressV.bounds.size.height / 2)
        progressV.addSubview(sliderView)
        
        progressV.frame = CGRect(x: 0, y: 5, width: frame.size.width, height: 5)
        self.addSubview(progressV)
        
        
        // 给滑条加一个手势 目的是为了点击滑条  进度端点就变成点击点位置
        self.isUserInteractionEnabled = true // 开交互
        let tap = UIPanGestureRecognizer.init(target: self, action: #selector(tapAction(tap:)))
        self.addGestureRecognizer(tap)
    }
    // 可视化编程 初始化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 点击进度条后执行的  手势事件
    @objc func tapAction(tap : UIPanGestureRecognizer)
    {
        let touchPoint: CGPoint = tap.location(in: self)
        // 设置进度条的进度  当前点击的点前面的长度  占整个宽度的百分比  就是当前的进度
        progressV.setProgress(Float(touchPoint.x / progressV.bounds.size.width) , animated: true)
        addAnimation(point: touchPoint)
        // 进度条改变了 出发代理执行代理事件  让用的地方可以相应的改变  比如音频视频的播放进度调整
        self.delegate?.NProgressView(neuronProgressView: progressV, changeProgress: progressV.progress)
        
    }

    // 重新把 子控件的滑块  布局到端点位置
    override  func layoutSubviews()
    {
        super.layoutSubviews()
        // 让小滑块的中心点 在进度的端点位置
        sliderView.center = CGPoint(x:CGFloat(progressV.progress) * self.bounds.size.width, y: progressV.bounds.size.height / 2);
    }
    
    //计算移动
    func addAnimation(point:CGPoint) {
        if 0 >= progressV.frame.origin.x && point.x <= progressV.frame.size.width {
            sliderView.mj_origin.x = point.x
        }
    }
    
    //结束之后和正在的时候调用代理
    func didCallDelegate(viewP:CGPoint) {
        delegate?.NProgressView(neuronProgressView: progressV, changeProgress:Float(viewP.x/progressV.center.x))
    }
    
}
