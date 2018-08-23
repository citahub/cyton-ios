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

class ImportWalletController: BaseViewController, UITextViewDelegate, UITextFieldDelegate, NEPickerViewDelegate, ImportWalletViewModelDelegate, QRCodeControllerDelegate {
    let viewModel = ImportWalletViewModel()

    var selectState = SelectButtonStates.keystoreState
    let nView =  NEPickerView()
    var selectFormatId = "0"

    @IBOutlet weak var keystoreButton: UIButton! // tag 2000
    @IBOutlet weak var helpWordButton: UIButton! // 2001
    @IBOutlet weak var privateKeyButton: UIButton! // 2002
    @IBOutlet weak var scrollView: UIScrollView!

    // keystore VIew
    @IBOutlet weak var keystoreNameTF: UITextField!
    @IBOutlet weak var keystorePasswordTF: UITextField!
    @IBOutlet weak var keystoreImportButton: UIButton!
    @IBOutlet weak var keystoreHeadView: UIView!
    @IBOutlet weak var keystoreQRButton: UIButton!

    // mnemonic View
    @IBOutlet weak var mnemonicQRButton: UIButton!
    @IBOutlet weak var mnemonicHeadView: UIView!
    @IBOutlet weak var formatTF: UITextField!
    @IBOutlet weak var mnemonicNameTF: UITextField!
    @IBOutlet weak var mnemonicPasswordTF: UITextField!
    @IBOutlet weak var mnemonicConfirmTF: UITextField!
    @IBOutlet weak var mnemonicImportButton: UIButton!

    // privatekey view
    @IBOutlet weak var privatekeyQRButton: UIButton!
    @IBOutlet weak var privatekeyHeadView: UIView!
    @IBOutlet weak var privatekeyNameTF: UITextField!
    @IBOutlet weak var privatekeyPasswordTF: UITextField!
    @IBOutlet weak var privatekeyConfirmTF: UITextField!

    private let keystoreTextView = RSKPlaceholderTextView()
    private let mnemonicTextView = RSKPlaceholderTextView()
    private let privatekeyTextView = RSKPlaceholderTextView()

    var lineStateView = UIView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch selectState {
        case .keystoreState:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        case .mnemonicState:
            scrollView.setContentOffset(CGPoint(x: ScreenW, y: 0), animated: false)
        case .privateKeyState:
            scrollView.setContentOffset(CGPoint(x: ScreenW*2, y: 0), animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        title = "导入钱包"
        viewModel.delegate = self
        didSetKeyStoreView()
        didSetMnemonicView()
        didSetPrivateKeyView()
    }

    // set keystore view
    func didSetKeyStoreView() {
        lineStateView.backgroundColor = ColorFromString(hex: "#2e4af2")
        lineStateView.frame = CGRect(x: 0, y: 43, width: ScreenW/3, height: 2)
        self.view.addSubview(lineStateView)
        keystoreNameTF.placeholder = "请输入名称"
        keystorePasswordTF.placeholder = "请输入密码"

        keystoreQRButton.addTarget(self, action: #selector(didClickQRButton(sender:)), for: .touchUpInside)

        keystoreTextView.autocorrectionType = .no
        keystoreTextView.spellCheckingType = .no
        mnemonicTextView.autocapitalizationType = .none
        keystoreTextView.delegate = self
        keystoreTextView.font = UIFont.systemFont(ofSize: 14)
        keystoreTextView.placeholder = "请导入keystore文本"
        keystoreTextView.layer.cornerRadius = 5
        keystoreTextView.layer.borderWidth = 1
        keystoreTextView.layer.borderColor = ColorFromString(hex: "#eeeeee").cgColor
        keystoreTextView.clipsToBounds = true
        keystoreHeadView.addSubview(keystoreTextView)
        keystoreTextView.backgroundColor = ColorFromString(hex: "#f5f5f5")
        keystoreTextView.translatesAutoresizingMaskIntoConstraints = false
        let letftContraint = NSLayoutConstraint(item: keystoreTextView, attribute: .left, relatedBy: .equal, toItem: keystoreHeadView, attribute: .leftMargin, multiplier: 1, constant: 7.5)
        let rightContraint = NSLayoutConstraint(item: keystoreTextView, attribute: .right, relatedBy: .equal, toItem: keystoreHeadView, attribute: .rightMargin, multiplier: 1, constant: -7.5)
        let topContraint = NSLayoutConstraint(item: keystoreTextView, attribute: .top, relatedBy: .equal, toItem: keystoreHeadView, attribute: .topMargin, multiplier: 1, constant: 7.5)
        let bottomContraint = NSLayoutConstraint(item: keystoreTextView, attribute: .bottom, relatedBy: .equal, toItem: keystoreHeadView, attribute: .bottomMargin, multiplier: 1, constant: -7.5)
        NSLayoutConstraint.activate([letftContraint, rightContraint, topContraint, bottomContraint])
        keystoreHeadView.addConstraints([letftContraint, rightContraint, topContraint, bottomContraint])

        let nameLab = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab.font = UIFont.systemFont(ofSize: 15)
        nameLab.textColor = ColorFromString(hex: "#333333")
        nameLab.text = "钱包名称"
        keystoreNameTF.leftViewMode = .always
        keystoreNameTF.leftView = nameLab
        let passwordLab = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        passwordLab.font = UIFont.systemFont(ofSize: 15)
        passwordLab.textColor = ColorFromString(hex: "#333333")
        passwordLab.text = "解锁密码"
        keystorePasswordTF.leftViewMode = .always
        keystorePasswordTF.leftView = passwordLab
        keystoreHeadView.bringSubview(toFront: keystoreQRButton)
    }

    // set mnemonic view
    func didSetMnemonicView() {
        mnemonicTextView.autocorrectionType = .no
        mnemonicTextView.spellCheckingType = .no
        mnemonicTextView.autocapitalizationType = .none
        mnemonicTextView.tag = 3001
        mnemonicQRButton.addTarget(self, action: #selector(didClickQRButton(sender:)), for: .touchUpInside)
        mnemonicNameTF.placeholder = "请输入名称"
        mnemonicPasswordTF.placeholder = "请输入密码"
        mnemonicConfirmTF.placeholder = "请确认密码"
        formatTF.delegate = self
        formatTF.leftViewMode = .always
        formatTF.rightViewMode = .always
        mnemonicNameTF.leftViewMode = .always
        mnemonicPasswordTF.leftViewMode = .always
        mnemonicConfirmTF.leftViewMode = .always

        mnemonicTextView.delegate = self
        mnemonicTextView.font = UIFont.systemFont(ofSize: 14)
        mnemonicTextView.placeholder = "助记词输入+空格"
        mnemonicTextView.layer.cornerRadius = 5
        mnemonicTextView.layer.borderWidth = 1
        mnemonicTextView.layer.borderColor = ColorFromString(hex: "#eeeeee").cgColor
        mnemonicTextView.clipsToBounds = true
        mnemonicHeadView.addSubview(mnemonicTextView)
        mnemonicTextView.backgroundColor = ColorFromString(hex: "#f5f5f5")
        mnemonicTextView.translatesAutoresizingMaskIntoConstraints = false
        let letftContraint = NSLayoutConstraint(item: mnemonicTextView, attribute: .left, relatedBy: .equal, toItem: mnemonicHeadView, attribute: .leftMargin, multiplier: 1, constant: 7.5)
        let rightContraint = NSLayoutConstraint(item: mnemonicTextView, attribute: .right, relatedBy: .equal, toItem: mnemonicHeadView, attribute: .rightMargin, multiplier: 1, constant: -7.5)
        let topContraint = NSLayoutConstraint(item: mnemonicTextView, attribute: .top, relatedBy: .equal, toItem: mnemonicHeadView, attribute: .topMargin, multiplier: 1, constant: 7.5)
        let bottomContraint = NSLayoutConstraint(item: mnemonicTextView, attribute: .bottom, relatedBy: .equal, toItem: mnemonicHeadView, attribute: .bottomMargin, multiplier: 1, constant: -7.5)
        NSLayoutConstraint.activate([letftContraint, rightContraint, topContraint, bottomContraint])
        mnemonicHeadView.addConstraints([letftContraint, rightContraint, topContraint, bottomContraint])

        let nameLab = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab.font = UIFont.systemFont(ofSize: 15)
        nameLab.textColor = ColorFromString(hex: "#333333")
        nameLab.text = "格式"
        let nameLab1 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab1.font = UIFont.systemFont(ofSize: 15)
        nameLab1.textColor = ColorFromString(hex: "#333333")
        nameLab1.text = "钱包名称"
        let nameLab2 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab2.font = UIFont.systemFont(ofSize: 15)
        nameLab2.textColor = ColorFromString(hex: "#333333")
        nameLab2.text = "设定密码"
        let nameLab3 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab3.font = UIFont.systemFont(ofSize: 15)
        nameLab3.textColor = ColorFromString(hex: "#333333")
        nameLab3.text = "重复密码"
        formatTF.leftView = nameLab
        mnemonicNameTF.leftView = nameLab1
        mnemonicPasswordTF.leftView = nameLab2
        mnemonicConfirmTF.leftView = nameLab3
        mnemonicHeadView.bringSubview(toFront: mnemonicQRButton)

        let firstBtn = UIButton(type: .custom)
        firstBtn.setImage(UIImage(named: "Triangle"), for: .normal)
        firstBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 50)
        firstBtn.addTarget(self, action: #selector(didSetUpPickView), for: .touchUpInside)
        formatTF.rightView = firstBtn
        formatTF.text = "m/44'/60'/0'/0/0"

        let tap = UITapGestureRecognizer(target: self, action: #selector(didSetUpPickView))
        formatTF.addGestureRecognizer(tap)
    }

    // set privatekey view
    func didSetPrivateKeyView() {
        privatekeyNameTF.placeholder = "请输入名称"
        privatekeyPasswordTF.placeholder = "请输入密码"
        privatekeyConfirmTF.placeholder = "请重新输入密码"
        privatekeyNameTF.leftViewMode = .always
        privatekeyPasswordTF.leftViewMode = .always
        privatekeyConfirmTF.leftViewMode = .always
        privatekeyQRButton.addTarget(self, action: #selector(didClickQRButton(sender:)), for: .touchUpInside)

        privatekeyHeadView.addSubview(privatekeyTextView)
        privatekeyTextView.autocorrectionType = .no
        privatekeyTextView.spellCheckingType = .no
        privatekeyTextView.autocapitalizationType = .none
        privatekeyTextView.delegate = self
        privatekeyTextView.font = UIFont.systemFont(ofSize: 14)
        privatekeyTextView.placeholder = "输入私钥原文"
        privatekeyTextView.layer.cornerRadius = 5
        privatekeyTextView.layer.borderWidth = 1
        privatekeyTextView.layer.borderColor = ColorFromString(hex: "#eeeeee").cgColor
        privatekeyTextView.clipsToBounds = true
        privatekeyTextView.backgroundColor = ColorFromString(hex: "#f5f5f5")
        privatekeyTextView.translatesAutoresizingMaskIntoConstraints = false
        let letftContraint = NSLayoutConstraint(item: privatekeyTextView, attribute: .left, relatedBy: .equal, toItem: privatekeyHeadView, attribute: .leftMargin, multiplier: 1, constant: 7.5)
        let rightContraint = NSLayoutConstraint(item: privatekeyTextView, attribute: .right, relatedBy: .equal, toItem: privatekeyHeadView, attribute: .rightMargin, multiplier: 1, constant: -7.5)
        let topContraint = NSLayoutConstraint(item: privatekeyTextView, attribute: .top, relatedBy: .equal, toItem: privatekeyHeadView, attribute: .topMargin, multiplier: 1, constant: 7.5)
        let bottomContraint = NSLayoutConstraint(item: privatekeyTextView, attribute: .bottom, relatedBy: .equal, toItem: privatekeyHeadView, attribute: .bottomMargin, multiplier: 1, constant: -7.5)
        NSLayoutConstraint.activate([letftContraint, rightContraint, topContraint, bottomContraint])
        privatekeyHeadView.addConstraints([letftContraint, rightContraint, topContraint, bottomContraint])

        privatekeyHeadView.bringSubview(toFront: privatekeyQRButton)

        let nameLab1 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab1.font = UIFont.systemFont(ofSize: 15)
        nameLab1.textColor = ColorFromString(hex: "#333333")
        nameLab1.text = "钱包名称"
        let nameLab2 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab2.font = UIFont.systemFont(ofSize: 15)
        nameLab2.textColor = ColorFromString(hex: "#333333")
        nameLab2.text = "设定密码"
        let nameLab3 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 49))
        nameLab3.font = UIFont.systemFont(ofSize: 15)
        nameLab3.textColor = ColorFromString(hex: "#333333")
        nameLab3.text = "重复密码"
        privatekeyNameTF.leftView = nameLab1
        privatekeyPasswordTF.leftView = nameLab2
        privatekeyConfirmTF.leftView = nameLab3
    }

    // pickview
    @objc func didSetUpPickView() {
        print("点击了pick")
        nView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        nView.delegate = self
        nView.dataArray = [["name": "m/44'/60'/0'/0/0", "id": "0"], ["name": "m/44'/60'/0'/0", "id": "1"], ["name": "m/44'/60'/1'/0/0", "id": "2"]]
        nView.selectDict = ["name": formatTF.text!, "id": selectFormatId]
        UIApplication.shared.keyWindow?.addSubview(nView)
    }

    // NEPickerViewDelegate
    func callBackDictionnary(dict: [String: String]) {
        formatTF.text = dict["name"]
        selectFormatId = dict["id"]!
    }

    // QRButton action
    @objc func didClickQRButton(sender: UIButton) {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    // QRCode deleagte
    func didBackQRCodeMessage(codeResult: String) {
        switch selectState {
        case .keystoreState:
            keystoreTextView.text = codeResult
        case .mnemonicState:
            mnemonicTextView.text = codeResult
        case .privateKeyState:
            privatekeyTextView.text = codeResult
        }
    }

    // textField delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === formatTF {
            didSetUpPickView()
            formatTF.resignFirstResponder()
        }
    }

    // three top button
    @IBAction func didClickKeystoreButton(_ sender: UIButton) {
        selectState = .keystoreState
        viewModel.importType = .keystoreType
        setTopButtonStateWithButton(sender: sender)
    }

    @IBAction func didClickHelpwordButton(_ sender: UIButton) {
        selectState = .mnemonicState
        viewModel.importType = .mnemonicType
        setTopButtonStateWithButton(sender: sender)
    }

    @IBAction func didClickPrivatekeyButton(_ sender: UIButton) {
        selectState = .privateKeyState
        viewModel.importType = .privateKeyType
        setTopButtonStateWithButton(sender: sender)
    }

    // set top button color
    func setTopButtonStateWithButton(sender: UIButton) {
        sender.setTitleColor(ColorFromString(hex: "#2e4af2"), for: .normal)
        print(sender.tag - 2000)
        lineStateView.frame = CGRect(x: CGFloat(ScreenW/3 * CGFloat(sender.tag - 2000)), y: 43, width: ScreenW/3, height: 2)
        if sender.tag == 2000 {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            helpWordButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
            privateKeyButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        } else if sender.tag == 2001 {
            scrollView.setContentOffset(CGPoint(x: ScreenW, y: 0), animated: true)
            keystoreButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
            privateKeyButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        } else if sender.tag == 2002 {
            scrollView.setContentOffset(CGPoint(x: ScreenW*2, y: 0), animated: true)
            helpWordButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
            keystoreButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        }
    }

    // nextButton action
    @IBAction func keystoreNextButton(_ sender: UIButton) {
        viewModel.importKeyStoreWallet(keyStore: keystoreTextView.text, password: keystorePasswordTF.text!, name: keystoreNameTF.text!)
    }

    @IBAction func mnemonicNextButton(_ sender: UIButton) {
        viewModel.importWalletWithMnemonic(
            mnemonic: mnemonicTextView.text,
            password: mnemonicPasswordTF.text!,
            confirmPassword: mnemonicConfirmTF.text!,
            devirationPath: formatTF.text!,
            name: mnemonicNameTF.text!
        )
    }

    @IBAction func privatekeyNextButton(_ sender: UIButton) {
        viewModel.importPrivateWallet(
            privateKey: privatekeyTextView.text,
            password: privatekeyPasswordTF.text!,
            confirmPassword: privatekeyConfirmTF.text!,
            name: privatekeyNameTF.text!
        )
    }

    // importWalletViewModelDelegate
    func didPopToRootView() {
        navigationController?.popToRootViewController(animated: true)
    }
}
