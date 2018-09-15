//
//  TAViewControllerCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

@objc protocol TAViewControllerCellDelegate {
    @objc optional func didCallbackCurrentProgress(progress: Float)
}

class TAViewControllerCell: UITableViewCell {
    //current progress
    var progress: Float = 0.0 {
        didSet {
            sView.setValue(progress, animated: true)
        }
    }

    var showGasPrice: String = ""{
        didSet {
            speedLabel.text = showGasPrice + " ether"
        }
    }

    weak var delegate: TAViewControllerCellDelegate!

    @IBOutlet weak var quickLabel: UILabel!
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var sView: UISlider!
    @IBOutlet weak var speedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        sView.maximumValue = 100.00
        sView.minimumValue = 1.00
        sView.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
    }

    @objc func sliderDidChange(slider: UISlider) {
        let finalValue = String(format: "%.2f", slider.value)
        let finalFloat = Float(finalValue)
        delegate.didCallbackCurrentProgress!(progress: finalFloat!)
    }
}
