//
//  AddAssetController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class AddAssetController: BaseViewController, UITableViewDelegate, UITableViewDataSource, AddAssetTableViewCellDelegate, NEPickerViewDelegate, QRCodeControllerDelegate {

    let titleArray = ["区块链", "合约地址", "代币名称", "代币缩写", "小数位数"]
    let placeholderArray = ["", "合约地址", "代币名称", "代币缩写", "小数位数"]

    let nView =  NEPickerView.init()
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var aTable: UITableView!
    var tokenModel = TokenModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "添加资产"
        view.backgroundColor = ColorFromString(hex: "f5f5f5")
        aTable.delegate = self
        aTable.dataSource = self
        aTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        aTable.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenW, height: CGFloat.leastNormalMagnitude))

    }

    @IBAction func didClickAddButton(_ sender: UIButton) {
        if tokenModel.address.count != 40 && tokenModel.address.count != 42 {
            NeuLoad.showToast(text: "请输入正确的合约地址")
            return
        }
        if tokenModel.name.isEmpty || tokenModel.symbol.isEmpty || String(tokenModel.decimals).isEmpty {
            NeuLoad.showToast(text: "Token信息不全，请核对合约地址是否正确")
            return
        }
        NeuLoad.showHUD(text: "")
        let appModel = WalletRealmTool.getCurrentAppmodel()
        if !tokenModel.address.hasPrefix("0x") {
            tokenModel.address = "0x" + tokenModel.address
        }
//        tokenModel.chainidName = 
        try? WalletRealmTool.realm.write {
            WalletRealmTool.realm.add(tokenModel, update: true)
            appModel.extraTokenList.append(tokenModel)
            appModel.currentWallet?.selectTokenList.append(tokenModel)
        }
        NeuLoad.hidHUD()
        navigationController?.popViewController(animated: true)
    }
    //tableview代理
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! AddAssetTableViewCell
        cell.delegate = self
        cell.indexP = indexPath as NSIndexPath
        cell.headLable.text = titleArray[indexPath.row]
        cell.placeHolderStr = placeholderArray[indexPath.row]
        cell.selectRow = indexPath.row
        if indexPath.row == 0 {
            cell.rightTextField.text = "以太坊"
        }

        switch indexPath.row {
        case 0:
            cell.rightTextField.text = "以太坊"
        case 1:
            cell.rightTextField.text = tokenModel.address
        case 2:
            cell.isEdit = false
            cell.rightTextField.text = tokenModel.name
        case 3:
            cell.isEdit = false
            cell.rightTextField.text = tokenModel.symbol
        case 4:
            cell.isEdit = false
            cell.rightTextField.text = tokenModel.decimals == 0 ?"":String(tokenModel.decimals)
        default:
            break
        }
        return cell
    }

    //cell的代理 弹出pickerview
    func didClickSelectCoinBtn() {
        nView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        nView.delegate = self
        nView.dataArray = [["name": "以太坊eth", "id": "100"], ["name": "Nervos", "id": "101"]]
        nView.selectDict = ["name": "以太坊eth", "id": "100"]
        UIApplication.shared.keyWindow?.addSubview(nView)
    }

    func callBackDictionnary(dict: [String: String]) {
        print(dict["name"]!)
    }

    func didClickQRCodeBtn() {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }

    func didBackQRCodeMessage(codeResult: String) {
        tokenModel.address = ""
        let finalText = codeResult.replacingOccurrences(of: " ", with: "")
        tokenModel.address = finalText
        if finalText.count == 40 || finalText.count == 42 {
            didGetERC20Token(token: finalText)
        }
        aTable.reloadData()
    }

    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        let finalText = text.replacingOccurrences(of: " ", with: "")
        self.tokenModel.address = finalText
        if index.row == 1 {
            if finalText.count == 40 || finalText.count == 42 {
                didGetERC20Token(token: finalText)
            } else {
            }
        }
    }

    func didGetERC20Token(token: String) {
        let appmodel = WalletRealmTool.getCurrentAppmodel()
        NeuLoad.showHUD(text: "")
        ERC20TokenService.addERC20TokenToApp(contractAddress: token, walletAddress: (appmodel.currentWallet?.address)!) { (result) in
            switch result {
            case .Success(let tokenM):
                self.tokenModel = tokenM
                self.tokenModel.address = token
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            NeuLoad.hidHUD()
            self.aTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
