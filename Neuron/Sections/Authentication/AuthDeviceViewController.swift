//
//  TouchIDAuthenticationViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthDeviceViewController: UIViewController, AuthenticationMode {
    weak var delegate: AuthenticationDelegate?
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authenticationButton: UIButton!
    @IBOutlet weak var authenticationTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthenticationService.shared.biometryType == .faceID {
            authenticationButton.setImage(UIImage(named: "faceId_icon"), for: .normal)
            authenticationTitleLabel.text = "Authentication.clickToAuthentication".localized() + " Face ID"
        } else {
            authenticationButton.setImage(UIImage(named: "touchId_icon"), for: .normal)
            authenticationTitleLabel.text = "Authentication.clickToAuthentication".localized() + " Touch ID"
        }
        deviceOwnerAuthentication()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func deviceOwnerAuthentication() {
        messageLabel.isHidden = true
        AuthenticationService.shared.deviceOwnerAuthentication { (result, error) in
            if result {
                self.delegate?.authenticationSuccessful()
            } else {
                guard let error = error else { return }
                self.messageLabel.isHidden = false
                self.messageLabel.text = error.stringValue
            }
        }
    }
}
