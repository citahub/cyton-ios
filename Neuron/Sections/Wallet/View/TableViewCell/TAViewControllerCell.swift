//
//  TAViewControllerCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

@objc protocol TAViewControllerCellDelegate {
    @objc optional func didCallbackCurrentProgress(progress:Float)
    
}

class TAViewControllerCell: UITableViewCell,NeuronProgressViewDelegate {
    
    //进度条的具体进度条
    var progress:Float = 0.0{
        didSet{
            if progress >= 0 || progress <= 1 {
                npView.progressV.progress = progress
            }else if progress < 0{
                npView.progressV.progress = 0
            }else{
                npView.progressV.progress = 1
            }
        }
    }
    weak var delegate:TAViewControllerCellDelegate!
    
    var npView = NeuronProgressView()
    @IBOutlet weak var speedLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        npView = NeuronProgressView.init(frame: CGRect(x: 15, y: 40, width: ScreenW - 30, height: 15))
        self.contentView.addSubview(npView)
    }
    
    func NProgressView(neuronProgressView: UIProgressView, changeProgress currenProgress: Float) {
        delegate.didCallbackCurrentProgress!(progress: currenProgress)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
