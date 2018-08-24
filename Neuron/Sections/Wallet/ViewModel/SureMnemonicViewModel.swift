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
    var walletPrivateKey = ""
    var walletPasswordMD5 = ""

    weak var delegate: SureMnemonicViewModelDelegate?
    typealias SureMnemonicViewModelBlcol = (_ str: String) -> Void
    var walletModel = WalletModel()

    // 验证助记词
    public func compareMnemonic(original: String, current: String) -> Bool {
        if original == current {
            return true
        } else {
            NeuLoad.showToast(text: "助记词验证失败")
            return false
        }
    }

    //导入钱包
    public func didImportWalletToRealm(mnemonic: String, password: String) {
        // 通过助记词导入钱包
        NeuLoad.showHUD(text: "钱包创建中...")

        WalletTools.importMnemonicAsync(mnemonic: mnemonic, password: password, devirationPath: WalletTools.defaultDerivationPath, completion: { (result) in
            switch result {
            case .succeed(let account):
                print(account)
                self.walletName = self.walletModel.name
                self.walletAddress = account.address.eip55String
                self.walletPasswordMD5 = CryptTools.changeMD5(password: password)
                self.exportKeystoreAndPirvateKey(account: account, password: password)
            case .failed(_, let errorMessage):
                NeuLoad.showToast(text: errorMessage)
            }
            NeuLoad.hidHUD()
        })
    }

    //export keystore
    func exportKeystoreAndPirvateKey(account: Account, password: String) {
        let privateKeyResult = WalletTools.exportPrivateKey(account: account, password: password)
        switch privateKeyResult {
        case .succeed(result: let privateKey):
            print(privateKey!)
            self.walletPrivateKey = CryptTools.Endcode_AES_ECB(strToEncode: privateKey!, key: password)
            saveWallet()
        case .failed(let errorStr, let errorMsg):
            NeuLoad.showToast(text: errorMsg)
            print(errorStr)
        }
    }

//    //生成keystore
//    func exportKeystoreStr(privateKey:String) {
//        let kS = WalletTools.convertPrivateKeyToJSON(hexPrivateKey: privateKey, password: walletModel.password)
//        switch kS {
//        case .succeed(let result):
//            self.walletKeyStore = result
//            print("keystore:" + result)
//            break
//        case .failed(let error,let errorMessage):
//            NeuLoad.showToast(text:errorMessage)
//            print(error)
//            break
//        }
//    }

    func saveWallet() {
        let appModel = WalletRealmTool.getCurrentAppmodel()
        let walletCount = appModel.wallets.count
        walletModel.address = walletAddress
        walletModel.encryptPrivateKey =  walletPrivateKey
        walletModel.MD5screatPassword = walletPasswordMD5
        let gitIcon = GitHubIdenticon.init()
        let iconImage = gitIcon.icon(from: walletModel.name, size: CGSize(width: 60, height: 60))
        let imageData = UIImagePNGRepresentation(iconImage!)
        walletModel.iconData = imageData
        try! WalletRealmTool.realm.write {
            appModel.currentWallet = walletModel
            appModel.wallets.append(walletModel)
            WalletRealmTool.addObject(appModel: appModel)
        }
        NeuLoad.showToast(text: "创建成功")
        if walletCount == 0 {
            changeTabbar()
        }
        delegate?.doPush()
        didPostCreatSuccessNotify()
    }

    private func didPostCreatSuccessNotify() {
        //send notification when wallet is created success,by the way send walletAddress
        NotificationCenter.default.post(name: .creatWalletSuccess, object: self, userInfo: ["post": walletModel.address])
    }

    //if creat wallet successful send changeTabbar notification
    func changeTabbar() {
        NotificationCenter.default.post(name: .changeTabbar, object: self)
    }

}
