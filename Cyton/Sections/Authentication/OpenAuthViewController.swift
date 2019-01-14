//
//  OpenAuthViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class OpenAuthViewController: UIViewController {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthenticationService.shared.biometryType == .faceID {
            iconView.image = UIImage(named: "faceId_icon")
            messageLabel.text = "Authentication.openFaceIdAuthDesc".localized()
            confirmButton.setTitle("Authentication.openFaceIdAuth".localized(), for: .normal)
        } else {
            iconView.image = UIImage(named: "touchId_icon")
            messageLabel.text = "Authentication.openTouchIdAuthDesc".localized()
            confirmButton.setTitle("Authentication.openTouchIdAuth".localized(), for: .normal)
        }
        cancelButton.setTitle("Authentication.notOpen".localized(), for: .normal)
    }

    @IBAction func confrim(_ sender: Any) {
        AuthenticationService.shared.setAuthenticationEnable(enable: true) { (result) in
            if result {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
