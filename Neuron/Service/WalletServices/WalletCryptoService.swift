//
//  WalletCryptoService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrezorCrypto
import TrustKeystore
import TrustCore

struct WalletCryptoService {
    static func updateEncryptPrivateKey(oldPassword: String, newPassword: String, walletAddress: String) {
        let ac = Address.init(eip55: (walletAddress))
        let account = WalletTools.keystore?.account(for: ac!)
        try! WalletTools.keystore?.update(account: account!, password: oldPassword, newPassword: newPassword)
    }

    static func didCheckoutKeystoreWithCurrentWallet(password: String) -> String {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        let walletPrivate = CryptoTool.Decode_AES_ECB(strToDecode: walletModel.encryptPrivateKey, key: password)
        let resultType = WalletTools.convertPrivateKeyToJSON(hexPrivateKey: walletPrivate, password: password)
        var keyStore = ""
        switch resultType {
        case .succeed(result: let keyStoreString):
            keyStore = keyStoreString
        case .failed(_, errorMessage:let errorMsg):
            Toast.showToast(text: errorMsg)
        }
        return keyStore
    }

    static func didDelegateWallet(password: String, walletAddress: String) {
        let address = Address.init(eip55: (walletAddress))
        let account = WalletTools.keystore?.account(for: address!)
        try! WalletTools.keystore?.delete(account: account!, password: password)
    }
}
