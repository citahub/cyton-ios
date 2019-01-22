//
//  NibLoadable.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol NibLoadable {
}

extension NibLoadable where Self: UIView {
    static func loadFromNib(_ nibname: String? = nil) -> Self {
        let loadName = nibname ?? "\(self)"
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}
