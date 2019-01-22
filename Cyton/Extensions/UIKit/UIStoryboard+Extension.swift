//
//  UIStoryboard+Extension.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self.classForCoder())
    }
}

extension UIViewController: StoryboardIdentifiable { }

extension UIStoryboard {
    enum Name: String {
        case authentication
        case settings
        case switchWallet
        case guide
        case addWallet
        case main
        case overlay
        case transactionHistory
        case sendTransaction
        case walletManagement
        case dAppBrowser
        case transactionDetails

        var capitalized: String {
            let capital = String(rawValue.prefix(1)).uppercased()
            return capital + rawValue.dropFirst()
        }
    }

    convenience init(name: Name, bundle storyboardBundleOrNil: Bundle? = nil) {
        self.init(name: name.capitalized, bundle: nil)
    }

    func instantiateViewController<VC: UIViewController>() -> VC {
        guard let controller = instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC else {
            fatalError("Error - \(#function): \(VC.storyboardIdentifier)")
        }
        return controller
    }
}
