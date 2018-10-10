//
//  WalletCryptoService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrezorCrypto
import TrustCore

struct WalletCryptoService {
    static func updatePassword(address: String, password: String, newPassword: String) throws {
        let wallet = WalletTools.wallet(for: address)!
        try WalletTools.keyStore.update(wallet: wallet, password: password, newPassword: newPassword)
    }

    static func deleteWallet(address: String, password: String) throws {
        let wallet = WalletTools.wallet(for: address)!
        try WalletTools.keyStore.delete(wallet: wallet, password: password)
    }

    static func getKeystoreForCurrentWallet(password: String) throws -> String {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        let wallet = WalletTools.wallet(for: walletModel.address)!
        let data = try WalletTools.keyStore.export(wallet: wallet, password: password, newPassword: password)
        return String(data: data, encoding: .utf8)!
    }
}
