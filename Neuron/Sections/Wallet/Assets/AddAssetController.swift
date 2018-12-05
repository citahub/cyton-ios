//
//  AddAssetController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AddAssetController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddAssetTableViewCellDelegate, NEPickerViewDelegate, QRCodeViewControllerDelegate {
    let titleArray = ["区块链", "合约地址"]
    let placeholderArray = ["", "合约地址"]

    let nView =  NEPickerView.init()
    var tokenArray: [TokenModel] = []
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var aTable: UITableView!
    var tokenModel = TokenModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "添加资产"
        aTable.delegate = self
        aTable.dataSource = self
        aTable.register(UINib(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
    }

    @IBAction func searchTokenButton(_ sender: UIButton) {
    }
    @IBAction func didClickAddButton(_ sender: UIButton) {
        Toast.hideHUD()
        if tokenModel.address.count != 40 && tokenModel.address.count != 42 {
            Toast.showToast(text: "请输入正确的合约地址")
            return
        }
        if tokenModel.name.isEmpty || tokenModel.symbol.isEmpty || String(tokenModel.decimals).isEmpty {
            Toast.showToast(text: "Token信息不全，请核对合约地址是否正确")
            return
        }
        if tokenArray.contains(where: { $0.address.lowercased() == tokenModel.address.lowercased() }) {
            Toast.showToast(text: "不可重复添加")
            return
        }
        let appModel = AppModel.current
        tokenModel.address = tokenModel.address.addHexPrefix()
        tokenModel.isNativeToken = false
        if let id = TokenModel.identifier(for: tokenModel) {
            tokenModel.identifier = id
        }
        let realm = try! Realm()
        try? realm.write {
            realm.add(tokenModel, update: true)
            appModel.extraTokenList.append(tokenModel)
            appModel.currentWallet?.selectTokenList.append(tokenModel)
        }
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! AddAssetTableViewCell
        cell.delegate = self
        cell.indexP = indexPath as NSIndexPath
        cell.headLabel.text = titleArray[indexPath.row]
        cell.placeHolderStr = placeholderArray[indexPath.row]
        cell.selectRow = indexPath.row
        if indexPath.row == 0 {
            cell.rightTextField.text = "以太坊"
        }
        cell.selectionStyle = .none

        switch indexPath.row {
        case 0:
            cell.rightTextField.text = "以太坊"
        case 1:
            cell.rightTextField.text = tokenModel.address
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func didClickSelectCoinBtn() {
        nView.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        nView.delegate = self
        nView.dataArray = [["name": "以太坊eth", "id": "100"], ["name": "test-chain", "id": "101"]]
        nView.selectDict = ["name": "以太坊eth", "id": "100"]
        UIApplication.shared.keyWindow?.addSubview(nView)
    }

    func callBackDictionnary(dict: [String: String]) {
    }

    func didClickQRCodeBtn() {
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        self.navigationController?.pushViewController(qrCodeViewController, animated: true)
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
        tokenModel.address = finalText
        if index.row == 1 {
            if finalText.count == 40 || finalText.count == 42 {
                didGetERC20Token(token: finalText)
            } else {
            }
        }
    }

    func didGetERC20Token(token: String) {
        tokenModel.name = ""
        tokenModel.symbol = ""
        tokenModel.decimals = 0

        let walletAddress = AppModel.current.currentWallet!.address
        Toast.showHUD()
        DispatchQueue.global().async {
            let result = try? CustomERC20TokenService.searchTokenData(contractAddress: token, walletAddress: walletAddress)
            DispatchQueue.main.async {
                Toast.hideHUD()
                if let tokenModel = result {
                    self.tokenModel = tokenModel
                    self.tokenModel.address = token
                } else {
                    Toast.showToast(text: "未查询到代币信息，请核对合约地址是否正确")
                }
                self.aTable.reloadData()
            }
        }
    }
}
