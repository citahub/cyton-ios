//
//  VerifyMnemonicViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import web3swift
import RealmSwift

class VerifyMnemonicViewController: UIViewController, ButtonTagViewDelegate, ButtonTagUpViewDelegate, NoScreenshot, EnterBackOverlayPresentable {
    private var showView: ButtonTagView! = nil
    private var selectView: ButtonTagUpView! = nil
    private var selectArray: [String] = []
    let sureButton = UIButton.init(type: .custom)
    private var titleArr: [String] = []
    var password = ""
    var mnemonic: String? {
        didSet {
            titleArr =  (mnemonic?.components(separatedBy: " "))!
        }
    }

    var walletModel = WalletModel()
    @IBOutlet weak var inputMnemonicTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Create.confirmMnemonic".localized()
        inputMnemonicTitleLabel.text = "Wallet.Create.confirmMnemonicDesc".localized()

        didDrawSubViews()
        setupEnterBackOverlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "NoScreenshot.title".localized(), message: "NoScreenshot.mnemonicMessage".localized())
    }

    func didDrawSubViews() {
        let screenSize = UIScreen.main.bounds
        selectView = ButtonTagUpView(frame: CGRect(x: 15, y: 15 + 35, width: screenSize.width - 30, height: 150))
        selectView.delegate = self
        view.addSubview(selectView)

        showView = ButtonTagView(frame: CGRect(x: 15, y: 15 + 35 + 15 + 150, width: screenSize.width - 30, height: 150))
        showView.delegate = self
        showView.titleArray = titleArr.shuffled()
        showView.backgroundColor = .white
        view.addSubview(showView)

        sureButton.frame = CGRect(x: 15, y: showView.frame.origin.y + showView.frame.size.height + 20, width: screenSize.width - 30, height: 44)
        sureButton.backgroundColor = UIColor(named: "control_disabled_bg_color") // TODO: should use isEnabled property
        sureButton.setTitleColor(UIColor(named: "control_disabled_title_color"), for: .normal)
        sureButton.setTitle("Wallet.Create.backupCompleted".localized(), for: .normal)
        sureButton.addTarget(self, action: #selector(didCompletBackupMnemonic), for: .touchUpInside)
        sureButton.layer.cornerRadius = 5
        sureButton.accessibilityIdentifier = "confirmButton"
        view.addSubview(sureButton)
    }

    // back selected button
    func callBackSelectButtonArray(array: [NSMutableDictionary]) {
        selectView.comArr = array
        selectArray.removeAll()
        for name in array {
            selectArray.append(name.value(forKey: "buttonTitle") as! String)
        }
        if selectArray.count == 12 {
            sureButton.isEnabled = true
            sureButton.backgroundColor = UIColor(named: "tint_color")
            sureButton.setTitleColor(.white, for: .normal)
        } else {
            sureButton.isEnabled = false
            sureButton.backgroundColor = UIColor(named: "control_disabled_bg_color")
            sureButton.setTitleColor(UIColor(named: "control_disabled_title_color"), for: .normal)
        }
    }

    // change button select status when click cancel button
    func didDeleteSelectedButton(backDict: NSMutableDictionary) {
        showView.deleteDict = backDict
        selectArray = selectArray.filter({ (title) -> Bool in
            return  backDict.value(forKey: "buttonTitle") as! String != title
        })
    }

    @objc func didCompletBackupMnemonic() {
        if selectArray.count != titleArr.count {
            Toast.showToast(text: "Wallet.Create.mnemonicValidationFailed".localized())
            return
        }
        let originalMnemonic = titleArr.joined()
        let selectMnemonic = selectArray.joined()
        let success = compareMnemonic(original: originalMnemonic, current: selectMnemonic)
        if success {
            importWallet(mnemonic: mnemonic!, password: password)
        } else {
            Toast.showToast(text: "Wallet.Create.mnemonicValidationFailed".localized())
        }
    }

    // Verify mnemonic
    func compareMnemonic(original: String, current: String) -> Bool {
        if original == current {
            return true
        } else {
            return false
        }
    }

    func importWallet(mnemonic: String, password: String) {
        Toast.showHUD(text: "Wallet.Create.walletCreation".localized())
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = try WalletManager.default.importMnemonic(mnemonic: mnemonic, password: password)
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    self.walletModel.address = EthereumAddress.toChecksumAddress(wallet.address)!
                    self.saveWalletToRealm()
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.hideHUD()
                    Toast.showToast(text: error.localizedDescription)
                }
            }
        }
    }

    private func saveWalletToRealm() {
        let appModel = AppModel.current
        let realm = try! Realm()
        try! realm.write {
            appModel.currentWallet = walletModel
            appModel.wallets.append(walletModel)
            realm.add(appModel)
        }
        DefaultTokenAndChain().addDefaultTokenToWallet(wallet: walletModel)
        navigationController?.popToRootViewController(animated: true)
        Toast.showToast(text: "Wallet.Create.createSuccess".localized())
    }
}
