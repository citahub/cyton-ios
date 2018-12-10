//
//  AddAssetController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AddAssetController: UIViewController, UITableViewDelegate, UITableViewDataSource, QRCodeViewControllerDelegate {

    var tokenArray: [TokenModel] = []
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    var tokenModel = TokenModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Assets.AddAssets.Title".localized()
        searchButton.setTitle("Assets.AddAssets.Search".localized(), for: .normal)
        rightBarButton.title = "Assets.AddAssets.ListSettings".localized()
    }

    @IBAction func listSettings(_ sender: UIBarButtonItem) {
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
//        let realm = try! Realm()
//        try? realm.write {
//            realm.add(tokenModel, update: true)
//            appModel.extraTokenList.append(tokenModel)
//            appModel.currentWallet?.selectTokenList.append(tokenModel)
//        }
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectChainTableViewCell") as! SelectChainTableViewCell

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contractAddressTableViewCell") as! ContractAddressTableViewCell

            return cell
        }
    }

    @IBAction func clickSelectChainButton(_ sender: UIButton) {

    }

    @IBAction func clickQRCodeButton(_ sender: UIButton) {
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
        table.reloadData()
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
                    Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
                }
                self.table.reloadData()
            }
        }
    }
}

