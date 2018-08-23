//
//  ViewController+Extension.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

extension UIViewController {
    var correctLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide
        } else {
            return view.layoutMarginsGuide
        }
    }
}
