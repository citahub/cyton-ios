//
//  ImportWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit


enum SelectButtonStates {
    case keystoreState
    case helpWordState
    case privateKeyState
}

class ImportWalletController: BaseViewController,UITableViewDelegate,UITableViewDataSource,ImportTextViewCellDelegate,AddAssetTableViewCellDelegate,QRCodeControllerDelegate {
    

    
    var selectState = SelectButtonStates.keystoreState
    
    var titleArray = [""]
    var placeholderArray = [""]
    var textViewPlactHolderStr = ""
    
    
    @IBOutlet weak var keystoreButton: UIButton!//tag 2000
    @IBOutlet weak var helpWordButton: UIButton!//2001
    @IBOutlet weak var privateKeyButton: UIButton!//2002
    @IBOutlet weak var importTable: UITableView!
    @IBOutlet weak var titleLable: UILabel!
    var lineStateView = UIView.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导入钱包"
        didSetPlactHolder()
        lineStateView.backgroundColor = ColorFromString(hex: "#2e4af2")
        lineStateView.frame = CGRect(x: 0, y: 43, width: ScreenW/3, height: 2)
        self.view.addSubview(lineStateView)
        importTable.delegate = self
        importTable.dataSource = self
        importTable.register(ImportTextViewCell.self, forCellReuseIdentifier: "ID1")
        importTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        
    }
    
    //顶部的三个按钮 尽量单纯剥离界面逻辑
    @IBAction func didClickKeystoreButton(_ sender: UIButton) {
        selectState = .keystoreState
        setTopButtonStateWithButton(sender: sender)
    }
    @IBAction func didClickHelpwordButton(_ sender: UIButton) {
        selectState = .helpWordState
        setTopButtonStateWithButton(sender: sender)
    }
    @IBAction func didClickPrivatekeyButton(_ sender: UIButton) {
        selectState = .privateKeyState
        setTopButtonStateWithButton(sender: sender)
    }
    
    //设置按钮颜色
    func setTopButtonStateWithButton(sender:UIButton) {
        sender.setTitleColor(ColorFromString(hex: "#2e4af2"), for: .normal)
        print(sender.tag - 2000)
        lineStateView.frame = CGRect(x: CGFloat(ScreenW/3 * CGFloat(sender.tag - 2000)), y: 43, width: ScreenW/3, height: 2)
        if sender.tag == 2000 {
            helpWordButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
            privateKeyButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        }else if sender.tag == 2001{
            keystoreButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
            privateKeyButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        }else if sender.tag == 2002{
            helpWordButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
            keystoreButton.setTitleColor(ColorFromString(hex: "#666666"), for: .normal)
        }
        didSetPlactHolder()
        importTable.reloadData()
    }
    
    //设置placeholder
    func didSetPlactHolder() {
        switch selectState {
        case .keystoreState:
            titleArray = ["钱包名称","解锁密码"]
            placeholderArray = ["请输入名称","请输入密码"]
            textViewPlactHolderStr = "请导入keystor文本"
            titleLable.text = "将以太坊官方钱包KeyStore文件内容粘贴至输入框，或通过扫描二维码输入。"
            break
        case .helpWordState:
            titleArray = ["格式","钱包名称","设定密码","重复密码"]
            placeholderArray = ["","请输入名称","请输入名称","请重现输入密码"]
            textViewPlactHolderStr = "助记词输入+空格"
            titleLable.text = "请输入钱包助记词并选择助记词格式。"
            break
        case .privateKeyState:
            titleArray = ["钱包名称","设定密码","重复密码"]
            placeholderArray = ["请输入名称","请输入密码","请重新输入密码"]
            textViewPlactHolderStr = "输入私钥原文"
            titleLable.text = "请将私钥粘贴至输入框，或通过扫描二维码输入。"
            break
        }
    }
    
    //tableview 代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return titleArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 135
        }else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1") as! ImportTextViewCell
            cell.delegate = self
            cell.placeHolderStr = textViewPlactHolderStr
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID") as! AddAssetTableViewCell
            cell.delegate = self
            cell.indexP = indexPath as NSIndexPath
            cell.headLable.text = titleArray[indexPath.row]
            cell.placeHolderStr = placeholderArray[indexPath.row]
            if selectState == .helpWordState && indexPath.row == 0{
                cell.selectRow = 0
                cell.rightTextField.text = "metamask/jaxx兼容"
            }else{
                cell.selectRow = 2
                cell.rightTextField.text = ""
            }
            return cell
        }
    }
    
    // AddAssetTableViewCell 代理
    //textfield的内容对应的NSIndexPath
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        print(text)
        print(index.row)
        switch selectState {
        case .keystoreState:
            break
        case .helpWordState:
            break
        case .privateKeyState: break
        }
    }
    //选择类型
    func didClickSelectCoinBtn() {
        print("点击了jaxx")
    }
    
    // ImportTextViewCell代理
    //textview上点击二维码
    func didClickQRBtn() {
        print("点击二维码")
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }
    
    //时刻获取到textview的输入
    func didGetTextViewText(text: String) {
        print(text)
    }
    
    //扫描二维码返回的内容
    func didBackQRCodeMessage(codeResult: String) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
