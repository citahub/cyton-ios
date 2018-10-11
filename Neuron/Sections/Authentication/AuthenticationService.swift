//
//  AuthenticationService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import LocalAuthentication

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
                    if #available(iOS 11.0, *) {
                        if error.code == LAError.biometryNotEnrolled ||
                            error.code == LAError.biometryNotAvailable ||
                            error.code == LAError.biometryLockout {
                            Toast.showToast(text: error.stringValue)
                            return
                        }
                    }
                    switch error {
                    case LAError.passcodeNotSet, LAError.touchIDLockout:
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
        let controller: AuthenticationViewController = UIStoryboard(storyboard: .authentication).instantiateViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: controller)
        window.backgroundColor = UIColor.orange
        window.makeKeyAndVisible()
        self.window = window
    }

    func closeAuthentication() {
        guard let window = window else { return }
        UIView.animate(withDuration: 0.4, animations: {
            window.transform = CGAffineTransform.init(translationX: 0, y: window.bounds.size.height)
        }, completion: { (_) in
            self.window = nil
        })
    }

    func deviceOwnerAuthentication(complection: @escaping (Bool, LAError?) -> Void) {
        recognitionFlag = true
        LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "请验证指纹") { (result, error: Error?) in
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
        if #available(iOS 11.0, *) {
            if code == LAError.biometryNotEnrolled {
                return "未设置 Face ID"
            } else if code == LAError.biometryNotAvailable {
                return "需要 Face ID 权限"
            } else if code == LAError.biometryLockout {
                return "多次验证失败被锁定"
            }
        }
        switch self {
        case LAError.passcodeNotSet:
            return "未设置 Touch ID"
        case LAError.touchIDLockout:
            return "多次验证失败被锁定"
        default:
            return "识别失败，请重试"
        }
    }
}
