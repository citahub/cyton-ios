//
//  GenerateMnemonicController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class GenerateMnemonicController: UIViewController, NoScreenshot, EnterBackOverlayPresentable, UIGestureRecognizerDelegate {
    var password = ""
    var walletModel = WalletModel()
    var mnemonic = ""
    @IBOutlet private weak var mnemonicTextView: UITextView!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var mnemonicWarnTitleLabel: UILabel!
    @IBOutlet private weak var mnemonicWarnLabel1: UILabel!
    @IBOutlet private weak var mnemonicWarnLabel2: UILabel!
    @IBOutlet private weak var mnemonicWarnLabel3: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Create.backupMnemonic".localized()
        nextButton.setTitle("Common.next".localized(), for: .normal)
        mnemonicWarnTitleLabel.text = "Wallet.Create.mnemonicWarnTitle".localized()
        mnemonicWarnLabel1.text = "Wallet.Create.mnemonicWarn1".localized()
        mnemonicWarnLabel2.text = "Wallet.Create.mnemonicWarn2".localized()
        mnemonicWarnLabel3.text = "Wallet.Create.mnemonicWarn3".localized()

        mnemonicTextView.text = mnemonic
        setupEnterBackOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isTranslucent = false
        setupOverlayBackBarButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        cancelOverlayBackBarButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "NoScreenshot.title".localized(), message: "NoScreenshot.mnemonicMessage".localized())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmMnemonic" {
            let verifyMnemonicViewController = segue.destination as! VerifyMnemonicViewController
            verifyMnemonicViewController.mnemonic = mnemonic
            verifyMnemonicViewController.password = password
            verifyMnemonicViewController.walletModel = walletModel
        }
    }

    // MARK: - BackBarButton
    private var overlayBackBarButton: UIControl?

    func setupOverlayBackBarButton() {
        overlayBackBarButton = UIControl(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        overlayBackBarButton!.addTarget(self, action: #selector(clickBackBarButton), for: .touchUpInside)
        navigationController?.navigationBar.addSubview(overlayBackBarButton!)
    }

    func cancelOverlayBackBarButton() {
        overlayBackBarButton?.removeFromSuperview()
    }

    @objc func clickBackBarButton() {
        let alert = UIAlertController(title: nil, message: "Wallet.Create.backCreateWalletAlert".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Common.confirm".localized(), style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Common.reject".localized(), style: .destructive, handler: { (_) in
            alert.dismiss(animated: false, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}
