//
//  SureMnemonicViewModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/15.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrustKeystore
import RealmSwift
import IGIdenticon

protocol SureMnemonicViewModelDelegate: class {
    func doPush()
}

class SureMnemonicViewModel: NSObject {
    var walletName = ""
    var walletAddress = ""

    weak var delegate: SureMnemonicViewModelDelegate?
    typealias SureMnemonicViewModelBlcol = (_ str: String) -> Void
    var walletModel = WalletModel()

    // 验证助记词
    public func compareMnemonic(original: String, current: String) -> Bool {
        if original == current {
            return true
        } else {
            Toast.showToast(text: "助记词验证失败")
            return false
        }
    }

    //导入钱包
    public func didImportWalletToRealm(mnemonic: String, password: String) {
        // 通过助记词导入钱包
        Toast.showHUD(text: "钱包创建中...")
        WalletTools.importMnemonicAsync(mnemonic: mnemonic, password: password, devirationPath: WalletTools.defaultDerivationPath, completion: { (result) in
            switch result {
            case .succeed(let account):
                self.walletName = self.walletModel.name
                self.walletAddress = account.address.eip55String
            case .failed(_, let errorMessage):
                Toast.showToast(text: errorMessage)
            }
            Toast.hideHUD()
        })
    }

    func saveWallet() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let isFirstWallet = appModel.wallets.count == 0
        walletModel.address = walletAddress
        let iconImage = GitHubIdenticon().icon(from: walletModel.address.lowercased(), size: CGSize(width: 60, height: 60))
        walletModel.iconData = iconImage!.pngData()
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
            appModel.wallets.append(walletModel)
            WalletRealmTool.addObject(appModel: appModel)
        }
        delegate?.doPush()
        if isFirstWallet {
            NotificationCenter.default.post(name: .firstWalletCreated, object: nil)
        }
        NotificationCenter.default.post(name: .createWalletSuccess, object: nil, userInfo: ["address": walletModel.address])
        Toast.showToast(text: "创建成功")
    }
}
