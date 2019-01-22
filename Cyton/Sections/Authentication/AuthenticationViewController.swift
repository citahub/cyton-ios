//
//  AuthenticationViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

protocol AuthenticationDelegate: class {
    func authenticationSuccessful()
    func switchAuthenticationMode()
}

protocol AuthenticationMode: class {
    var view: UIView! { get }
    var delegate: AuthenticationDelegate? { get set }
}

class AuthenticationViewController: UIViewController, AuthenticationDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var switchImageView: UIImageView!
    @IBOutlet weak var otherTitleLabel: UILabel!
    var currentMode: AuthenticationMode?

    override func viewDidLoad() {
        super.viewDidLoad()
        switchImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchAuthenticationMode)))
        switchAuthenticationMode()
        if AppModel.current.wallets.count == 0 {
            otherTitleLabel.isHidden = true
            switchImageView.isHidden = true
        }
        otherTitleLabel.text = "Authentication.otherMode".localized()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func switchAuthenticationMode() {
        if (currentMode as? AuthDeviceViewController) == nil {
            switchImageView.image = UIImage(named: "password_login_icon")
            let mode: AuthDeviceViewController = storyboard!.instantiateViewController()
            change(mode: mode)
        } else {
            if AuthenticationService.shared.biometryType == .faceID {
                switchImageView.image = UIImage(named: "faceId_login_icon")
            } else {
                switchImageView.image = UIImage(named: "touchId_login_icon")
            }
            let mode: AuthPasswordViewController = storyboard!.instantiateViewController()
            change(mode: mode)
        }
    }

    func change(mode: AuthenticationMode) {
        currentMode = mode
        mode.delegate = self
        mode.view.frame = contentView.frame
        contentView.addSubview(mode.view)
    }

    // MAKR: - AuthenticationDelegate
    func authenticationSuccessful() {
        AuthenticationService.shared.closeAuthentication()
    }
}
