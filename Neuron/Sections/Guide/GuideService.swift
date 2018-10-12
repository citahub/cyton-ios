//
//  GuideService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class GuideService {
    static let shared = GuideService()
    var window: UIWindow?
    private var notificationToken: NotificationToken?

    private init() {
        notificationToken = WalletRealmTool.realm.objects(AppModel.self).observe { [weak self](change) in
            guard let self = self else { return }
            switch change {
            case .update(let values, deletions: _, insertions: _, modifications: _):
                if values.first?.wallets.count == 0 || values.count == 0 {
                    self.showGuide()
                } else {
                    self.hideGuide()
                }
            default:
                break
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }

    func register() {
        guard WalletRealmTool.getCurrentAppModel().wallets.count == 0 else { return }
        showGuide()
    }

    private func showGuide() {
        guard window == nil else { return }
        let controller: GuideViewController = UIStoryboard(storyboard: .guide).instantiateViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = BaseNavigationController(rootViewController: controller)
        window?.windowLevel = .alert
        window?.makeKeyAndVisible()
    }

    private func hideGuide() {
        guard let window = window else { return }
        UIView.animate(withDuration: 0.4, animations: {
            window.transform = CGAffineTransform.init(translationX: 0, y: window.bounds.size.height)
        }, completion: { (_) in
            self.window = nil
        })
    }
}
