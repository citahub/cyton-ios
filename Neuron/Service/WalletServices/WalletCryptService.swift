//
//  WalletCryptService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrezorCrypto
import TrustKeystore
import TrustCore

class WalletCryptService: NSObject {

    static public func updateEncryptPrivateKey(oldPassword: String, newPassword: String, walletAddress: String) {
        let ac = Address.init(eip55: (walletAddress))
        let account = WalletTools.keyStore?.account(for: ac!)
        try! WalletTools.keyStore?.update(account: account!, password: oldPassword, newPassword: newPassword)
    }

    static public func didCheckoutKeyStoreWithCurrentWallet(password: String) -> String {
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        let walletPrivate = CryptTools.Decode_AES_ECB(strToDecode: walletModel.encryptPrivateKey, key: password)
        let resultType = WalletTools.convertPrivateKeyToJSON(hexPrivateKey: walletPrivate, password: password)
        var keyStore = ""
        switch resultType {
        case .succeed(result: let keystoreStr):
            keyStore = keystoreStr
        case .failed(_, errorMessage:let errorMsg):
            NeuLoad.showToast(text: errorMsg)
        }
        return keyStore
    }

    static public func didDelegateWallet(password: String, walletAddress: String) {
        let address = Address.init(eip55: (walletAddress))
        let account = WalletTools.keyStore?.account(for: address!)
        try! WalletTools.keyStore?.delete(account: account!, password: password)
    }

}
