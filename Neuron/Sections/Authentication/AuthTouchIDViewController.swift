//
//  TouchIDAuthenticationViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthTouchIDViewController: UIViewController, AuthenticationMode {
    weak var delegate: AuthenticationDelegate?
    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        fingerprintRecognition()
    }

    @IBAction func fingerprintRecognition() {
        messageLabel.isHidden = true
        AuthenticationService.shared.fingerprintRecognition { (result, error) in
            if result {
                self.delegate?.authenticationSuccessful()
            } else {
                guard let error = error else { return }
                switch error {
//                case LAError.userFallback:
//                    self.delegate?.switchAuthenticationMode()
                default:
                    self.messageLabel.isHidden = false
                    self.messageLabel.text = error.stringValue
                }
            }
        }
    }
}
