//
//  NoScreenshot.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/9.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol NoScreenshot { }

private var NoScreenshotOnceTokenAssiciationKey = 0

extension NoScreenshot where Self: UIViewController {
    func showNoScreenshotAlert(titile: String, message: String) {
        guard objc_getAssociatedObject(self, &NoScreenshotOnceTokenAssiciationKey) == nil else { return }
        objc_setAssociatedObject(self, &NoScreenshotOnceTokenAssiciationKey, 2233, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let alert = UIAlertController(title: titile, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Common.confirm".localized(), style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
