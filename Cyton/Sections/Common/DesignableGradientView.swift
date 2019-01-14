//
//  DesignableGradientView.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

@IBDesignable class DesignableGradientView: UIView {
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    @IBInspectable var startPoint: CGPoint = .zero {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }

    @IBInspectable var endPoint: CGPoint = .zero {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }

    @IBInspectable var color1: UIColor? {
        didSet {
            gradientLayer.colors = colors
        }
    }

    @IBInspectable var color2: UIColor? {
        didSet {
            gradientLayer.colors = colors
        }
    }

    @IBInspectable var color3: UIColor? {
        didSet {
            gradientLayer.colors = colors
        }
    }

    var colors: [CGColor] {
        var colors = [CGColor]()
        if let color = color1 {
            colors.append(color.cgColor)
        }
        if let color = color2 {
            colors.append(color.cgColor)
        }
        if let color = color3 {
            colors.append(color.cgColor)
        }
        return colors
    }
}
