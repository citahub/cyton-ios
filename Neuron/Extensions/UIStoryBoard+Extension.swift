//
//  UIStoryBoard+Extension.swift
//  Neuron
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
        var rawValue: String {
            let string = "\(self)"
            let prefixRange = Range(uncheckedBounds: (string.startIndex, string.index(after: string.startIndex)))
            let prefix = string[prefixRange]
            return prefix.replacingCharacters(in: prefixRange, with: prefix.uppercased())
        }
    }

    convenience init(storyboard: Name, bundle storyboardBundleOrNil: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: nil)
    }

    func instantiateViewController<VC: UIViewController>() -> VC {
        guard let controller = instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC else {
            fatalError("Error - \(#function): \(VC.storyboardIdentifier)")
        }
        return controller
    }
}
