//
//  ShowTokenPageItem.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BLTNBoard

class ShowTokenPageItem: BLTNPageItem {
    private let tokenMessageView = ShowTokenMessageView.loadFromNib("TokenMessageView")
    static func create() -> ShowTokenPageItem {
        let item = ShowTokenPageItem(title: "Assets.AddAssets.TokenMessage".localized())
        item.appearance = PageItemAppearance.default
        item.actionButtonTitle = "Common.confirm".localized()
        return item
    }

    func update(tokenModel: TokenModel) {
        tokenMessageView.nameLabel.text = tokenModel.name
        tokenMessageView.decimalsLabel.text = String(tokenModel.decimals)
        tokenMessageView.symbolLabel.text = tokenModel.symbol
    }

    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        return [tokenMessageView]
    }
}

class ShowTokenMessageView: UIView, NibLoadable {
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var symbolTitleLabel: UILabel!
    @IBOutlet weak var decimalsTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var decimalsLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
}
