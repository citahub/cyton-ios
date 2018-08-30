//
//  ImportWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//
//  Should Reconstruction !!!

import UIKit
import RSKPlaceholderTextView

enum SelectButtonStates {
    case keystoreState
    case mnemonicState
    case privateKeyState
}

class ImportWalletController: UIViewController {

    @IBOutlet weak var keystore: UIButton!
    @IBOutlet weak var mnemonic: UIButton!
    @IBOutlet weak var privatekey: UIButton!
    @IBOutlet weak var slider: UIView!

    var currentStates: SelectButtonStates! {
        didSet {
            topButtonAndSliderPositionChanged(states: currentStates)
        }
    }
    var pageViewController: ImportWalletPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导入钱包"
        currentStates = .keystoreState
    }
    @IBAction func changeToKestore(_ sender: UIButton) {
        currentStates = .keystoreState
    }
    @IBAction func changeToMnemonic(_ sender: UIButton) {
        currentStates = .mnemonicState
    }
    @IBAction func changeToPrivatekey(_ sender: UIButton) {
        currentStates = .privateKeyState
    }
    func topButtonAndSliderPositionChanged(states: SelectButtonStates) {
        keystore.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        mnemonic.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        privatekey.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        switch states {
        case .keystoreState:
            keystore.setTitleColor(themeColor, for: .normal)
            slider.center.x = keystore.center.x
//            pageViewController.pages.forEach { (importViewController) in
                pageViewController.setViewControllers([pageViewController.pages[0]], direction: .reverse, animated: true, completion: nil)
//            }
        case .mnemonicState:
            mnemonic.setTitleColor(themeColor, for: .normal)
            slider.center.x = mnemonic.center.x
            pageViewController.setViewControllers([pageViewController.pages[1]], direction: .reverse, animated: true, completion: nil)
        case .privateKeyState:
            privatekey.setTitleColor(themeColor, for: .normal)
            slider.center.x = privatekey.center.x
            pageViewController.setViewControllers([pageViewController.pages[2]], direction: .forward, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "importWalletPageViewController" {
            pageViewController = segue.destination as? ImportWalletPageViewController
        }
    }

}
