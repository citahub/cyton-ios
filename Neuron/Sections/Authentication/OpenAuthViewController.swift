//
//  OpenAuthViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class OpenAuthViewController: UIViewController {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthenticationService.shared.biometryType == .faceID {
            iconView.image = UIImage(named: "faceId_icon")
            messageLabel.text = "请开启刷脸验证，确保您的资产安全"
            confirmButton.setTitle("开启刷脸验证", for: .normal)
        } else {
            iconView.image = UIImage(named: "touchId_icon")
            messageLabel.text = "请开启指纹验证，确保您的资产安全"
            confirmButton.setTitle("开启指纹验证", for: .normal)
        }
    }

    @IBAction func confrim(_ sender: Any) {
        AuthenticationService.shared.deviceOwnerAuthentication { (result, error) in
            if result {
                self.dismiss(animated: true, completion: nil)
            } else {
                guard let error = error else { return }
                Toast.showToast(text: error.stringValue)
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
