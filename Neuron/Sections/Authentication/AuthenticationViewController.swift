//
//  AuthenticationViewController.swift
//  Neuron
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
        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = true
        switchImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchAuthenticationMode)))
        switchAuthenticationMode()
        if WalletRealmTool.getCurrentAppModel().wallets.count == 0 {
            otherTitleLabel.isHidden = true
            switchImageView.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func switchAuthenticationMode() {
        if (currentMode as? AuthTouchIDViewController) == nil {
            switchImageView.image = UIImage(named: "password_login_icon")
            let mode: AuthTouchIDViewController = storyboard!.instantiateViewController()
            change(mode: mode)
        } else {
            switchImageView.image = UIImage(named: "fingerprint_login_icon")
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
