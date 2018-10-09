//
//  NoScreenshot.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/9.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

protocol NoScreenshot { }

extension NoScreenshot where Self: UIViewController {
    func showNoScreenshotAlert(titile: String, message: String) {
        let alert = UIAlertController(title: titile, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
