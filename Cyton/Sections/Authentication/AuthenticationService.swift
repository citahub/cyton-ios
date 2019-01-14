//
//  AuthenticationService.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import LocalAuthentication
import RealmSwift

class AuthenticationService {
    enum UserDefaultsKey: String {
        case enable
        var rawValue: String {
            return "\(AuthenticationService.self)_\(self)"
        }
    }
    enum BiometryType {
        case none
        case touchID
        case faceID
    }

    let biometryType: BiometryType
    var isValid: Bool {
        return biometryType != BiometryType.none
    }
    var isEnable: Bool {
        return UserDefaults.standard.bool(forKey: AuthenticationService.UserDefaultsKey.enable.rawValue)
    }
    var timeout: TimeInterval = 30.0
    static let shared = AuthenticationService()

    private var willResignActiveDate: Date?
    private var window: UIWindow?
    private var recognitionFlag = false
    private var notificationToken: NotificationToken?

    private init() {
        var error: NSError?
        let laContext = LAContext()
         if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            if #available(iOS 11.0, *) {
                if laContext.biometryType == LABiometryType.faceID {
                    biometryType = BiometryType.faceID
                } else {
                    biometryType = BiometryType.touchID
                }
            } else {
                biometryType = BiometryType.touchID
            }
        } else {
            biometryType = BiometryType.none
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)

        let realm = try! Realm()
        notificationToken = realm.objects(WalletModel.self).observe { (change) in
            switch change {
            case .update(let values, deletions: _, let insertions, modifications: _):
                guard !AuthenticationService.shared.isEnable else { return }
                guard values.count == 1 else { return }
                guard let index = insertions.first else { return }
                guard index == 0 else { return }
                DispatchQueue.main.async {
                    let controller: OpenAuthViewController = UIStoryboard(name: .authentication).instantiateViewController()
                    UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }

    func register() { }

    // MARK: - Enable
    func setAuthenticationEnable(enable: Bool, complection:@escaping (Bool) -> Void) {
        guard enable != isEnable else {
            complection(enable)
            return
        }
        if enable {
            deviceOwnerAuthentication { (result, error) in
                if result {
                    UserDefaults.standard.set(true, forKey: AuthenticationService.UserDefaultsKey.enable.rawValue)
                    complection(true)
                } else {
                    complection(false)
                    guard let error = error else { return }
                    switch error {
                    case LAError.passcodeNotSet,
                         LAError.biometryLockout,
                         LAError.biometryNotAvailable,
                         LAError.biometryNotEnrolled:
                        Toast.showToast(text: error.stringValue)
                    default:
                        break
                    }
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: AuthenticationService.UserDefaultsKey.enable.rawValue)
            complection(false)
        }
    }

    // MARK: Authentication
    func authentication() {
        guard self.window == nil else { return }
        guard willResignActiveDate == nil || willResignActiveDate! + timeout < Date() else {
            return
        }
        let controller: AuthenticationViewController = UIStoryboard(name: .authentication).instantiateViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: controller)
        window.backgroundColor = UIColor.orange
        window.makeKeyAndVisible()
        self.window = window
    }

    func closeAuthentication() {
        guard let window = window else { return }
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            window.transform = CGAffineTransform.init(translationX: 0, y: window.bounds.size.height)
        }, completion: { (_) in
            self.window = nil
        })
    }

    func deviceOwnerAuthentication(complection: @escaping (Bool, LAError?) -> Void) {
        recognitionFlag = true
        let localizedReason: String
        if biometryType == .faceID {
            localizedReason = "Authentication.authFaceIdTitle".localized()
        } else if biometryType == .touchID {
            localizedReason = "Authentication.authTouchIdTitle".localized()
        } else {
            return
        }
        LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason) { (result, error: Error?) in
            DispatchQueue.main.async {
                if result {
                    complection(true, nil)
                } else {
                    guard let error = error as NSError? else {
                        complection(false, nil)
                        return
                    }
                    let errorType = LAError(_nsError: error)
                    complection(false, errorType)
                }
            }
        }
    }

    // MARK: - Notification
    @objc private func didBecomeActiveNotification() {
        guard isValid else { return }
        guard isEnable else { return }
        guard !recognitionFlag else {
            recognitionFlag = false
            return
        }
        authentication()
        willResignActiveDate = nil
    }
    @objc private func willResignActiveNotification() {
        guard isEnable else { return }
        willResignActiveDate = Date()
    }
}

extension LAError {
    var stringValue: String {
        switch self {
        case LAError.biometryNotEnrolled:
            return "Authentication.Error.faceIDNotEnrolled".localized()
        case LAError.biometryNotAvailable:
            return "Authentication.Error.faceIDNotAvailable".localized()
        case LAError.passcodeNotSet:
            return "Authentication.Error.touchIDNotEnrolled".localized()
        case LAError.biometryLockout:
            return "Authentication.Error.biometryLockout".localized()
        default:
            return "Authentication.Error.authFailed".localized()
        }
    }
}
