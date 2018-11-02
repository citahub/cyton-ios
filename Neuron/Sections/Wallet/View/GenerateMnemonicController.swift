//
//  GenerateMnemonicController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class GenerateMnemonicController: UIViewController, NoScreenshot, EnterBackOverlayPresentable, UIGestureRecognizerDelegate {
    var password = ""
    var walletModel = WalletModel()
    var mnemonicStr = ""
    @IBOutlet weak var mnemonic: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mnemonic.text = mnemonicStr
        title = "备份助记词"
        setupEnterBackOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupOverlayBackBarButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        cancelOverlayBackBarButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "禁止截屏！", message: "拥有助记词就能完全控制该地址下的资产，建议抄写并放在安全的地方！")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmMnemonic" {
            let verifyMnemonicViewController = segue.destination as! VerifyMnemonicViewController
            verifyMnemonicViewController.mnemonic = mnemonicStr
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
        let alert = UIAlertController(title: nil, message: "距离开启您的安全区块链账户还差最后一步，是否继续", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "拒绝", style: .destructive, handler: { (_) in
            alert.dismiss(animated: false, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}
