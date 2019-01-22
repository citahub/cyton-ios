//
//  TabbedButtonsView.swift
//  Cyton
//
//  Created by Yate Fulham on 2018/08/30.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol TabbedButtonsViewDelegate: class {
    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int)
}

@IBDesignable
class TabbedButtonsView: UIView {
    @IBOutlet weak var underlineCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainer: UIStackView!

    var contentView: UIView?

    weak var delegate: TabbedButtonsViewDelegate?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 44)
    }

    @IBInspectable
    var selectedIndex: Int = -1 {
        didSet {
            updateState()
            setNeedsDisplay()
        }
    }

    @IBInspectable
    var margin: CGFloat = 20 {
        didSet {
            buttonContainerWidthContraint.constant = -margin * 2
            setNeedsUpdateConstraints()
        }
    }

    @IBInspectable
    var underlineWith: CGFloat = 100 {
        didSet {
            underlineWidthConstraint.constant = underlineWith
            setNeedsUpdateConstraints()
        }
    }

    var buttonTitles: [String] = [] {
        didSet {
            buildButtons()
        }
    }

    var buttons: [UIButton] {
        return buttonContainer.arrangedSubviews.compactMap { $0 as? UIButton }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
}

private extension TabbedButtonsView {
    func setupXib() {
        contentView = loadViewFromNib()
        contentView!.frame = bounds
        contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView!)
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: type(of: self).description().components(separatedBy: ".").last!, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView
    }

    func buildButtons() {
        buttonContainer.arrangedSubviews.forEach { button in
            button.removeFromSuperview()
        }

        buttonTitles.forEach { title in
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor(hex: "#8A8D9F"), for: .normal)
            button.setTitleColor(UIColor(hex: "#242B43"), for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            buttonContainer.addArrangedSubview(button)
        }

        if buttonTitles.count > 0 {
            selectedIndex = 0
        }
    }

    var buttonWidth: CGFloat {
        return (frame.width - margin * 2) / CGFloat(buttonTitles.count)
    }

    func updateState() {
        if buttonTitles.isEmpty {
            return
        }
        for (index, button) in buttons.enumerated() {
            button.isSelected = index == selectedIndex
        }
        underlineCenterXConstraint.constant =  buttonWidth * CGFloat(selectedIndex) + buttonWidth / 2
    }

    @objc
    func buttonTapped(sender: UIButton) {
        if let index = buttons.firstIndex(of: sender) {
            selectedIndex = index
            delegate?.tabbedButtonsView(self, didSelectButtonAt: index)
        }
    }
}
