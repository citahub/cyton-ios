//
//  DesignableButton.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton: UIButton {
    @IBInspectable var imageFrame: CGRect = .zero
    @IBInspectable var titleFrame: CGRect = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        if imageFrame != .zero {
            imageView?.frame = imageFrame
        }
        if titleFrame != .zero {
            titleLabel?.frame = titleFrame
        }
    }
}
