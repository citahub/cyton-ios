//
//  GuideService.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class GuideService {
    static let shared = GuideService()
    private var window: UIWindow?
    private var notificationToken: NotificationToken?

    private init() {
        let realm = try! Realm()
        notificationToken = realm.objects(AppModel.self).observe { [weak self](change) in
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
        guard AppModel.current.wallets.count == 0 else { return }
        showGuide()
    }

    private func showGuide() {
        guard window == nil else { return }
        let guideController: GuideViewController = UIStoryboard(name: .guide).instantiateViewController()
        let controller = BaseNavigationController(rootViewController: guideController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()

        let height = window?.bounds.size.height ?? 0.0
        window?.transform = CGAffineTransform(translationX: 0, y: height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.window?.transform = CGAffineTransform.identity
        }
    }

    private func hideGuide() {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            let height = self.window?.bounds.size.height ?? 0.0
            self.window?.transform = CGAffineTransform(translationX: 0, y: height)
        }, completion: { (_) in
            self.window?.rootViewController = nil
            self.window?.resignKey()
            self.window = nil
        })
    }
}
