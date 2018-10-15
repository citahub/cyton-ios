//
//  VerifyMnemonicViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class VerifyMnemonicViewController: UIViewController, ButtonTagViewDelegate, ButtonTagUpViewDelegate, SureMnemonicViewModelDelegate, NoScreenshot, EnterBackOverlayPresentable {
    private var showView: ButtonTagView! = nil
    private var selectView: ButtonTagUpView! = nil
    private var selectArray: [String] = []

    let sureButton = UIButton.init(type: .custom)

    private var titleArr: [String] = []
    var viewModel = SureMnemonicViewModel()
    var password = ""
    var mnemonic: String? {
        didSet {
            titleArr =  (mnemonic?.components(separatedBy: " "))!
        }
    }

    var walletModel = WalletModel() {
        didSet {
            viewModel.walletModel = walletModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "确认助记词"
        didDrawSubViews()
        viewModel.delegate = self
        setupEnterBackOverlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "禁止截屏！", message: "拥有助记词就能完全控制该地址下的资产，建议抄写并放在安全的地方！")
    }

    func didDrawSubViews() {
        selectView = ButtonTagUpView(frame: CGRect(x: 15, y: 15 + 35, width: ScreenSize.width - 30, height: 150))
        selectView.delegate = self
        view.addSubview(selectView)

        showView = ButtonTagView(frame: CGRect(x: 15, y: 15 + 35 + 15 + 150, width: ScreenSize.width - 30, height: 150))
        showView.delegate = self
        showView.titleArray = titleArr.shuffled()
        showView.backgroundColor = .white
        view.addSubview(showView)

        sureButton.frame = CGRect(x: 15, y: showView.frame.origin.y + showView.frame.size.height + 20, width: ScreenSize.width - 30, height: 44)
        sureButton.backgroundColor = ColorFromString(hex: "#f2f2f2")
        sureButton.setTitleColor(ColorFromString(hex: "#999999"), for: .normal)
        sureButton.setTitle("完成备份", for: .normal)
        sureButton.addTarget(self, action: #selector(didCompletBackupMnemonic), for: .touchUpInside)
        sureButton.layer.cornerRadius = 5
        view.addSubview(sureButton)
    }

    //选择按钮的时候返回的选择的数组
    func callBackSelectButtonArray(array: [NSMutableDictionary]) {
        selectView.comArr = array
        selectArray.removeAll()
        for name in array {
            selectArray.append(name.value(forKey: "buttonTitle") as! String)
        }
        if selectArray.count == 12 {
            sureButton.isEnabled = true
            sureButton.backgroundColor = AppColor.themeColor
            sureButton.setTitleColor(.white, for: .normal)
        } else {
            sureButton.isEnabled = false
            sureButton.backgroundColor = ColorFromString(hex: "#f2f2f2")
            sureButton.setTitleColor(ColorFromString(hex: "#999999"), for: .normal)
        }
    }

    //点击删除按钮的时候 下方按钮改变选中状态
    func didDeleteSelectedButton(backDict: NSMutableDictionary) {
        showView.deleteDict = backDict
        selectArray = selectArray.filter({ (title) -> Bool in
            return  backDict.value(forKey: "buttonTitle") as! String != title
        })
    }

    @objc func didCompletBackupMnemonic() {
        if selectArray.count != titleArr.count {
            Toast.showToast(text: "助记词验证失败")
            return
        }
        let originalMnemonic = titleArr.joined()
        let selectMnemonic = selectArray.joined()
        let success = viewModel.compareMnemonic(original: originalMnemonic, current: selectMnemonic)
        if success {
            viewModel.importWallet(mnemonic: mnemonic!, password: password)
        }
    }

    func doPush() {
        navigationController?.popToRootViewController(animated: true)
    }
}
