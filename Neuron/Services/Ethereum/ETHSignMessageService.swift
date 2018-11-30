//
//  ETHSignMessageService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain

struct ETHSignMessageService {
    enum Error: String, LocalizedError {
        case walletNotFound
        case signMessageFailed

        var errorDescription: String? {
            return "ETHSignMessageService.Error.\(rawValue)".localized()
        }
    }

    public static func sign(message: String, password: String) throws -> String {
        let messageData = Data.fromHex(message) ?? Data()
        let walletModel = AppModel.current.currentWallet!
        guard let wallet = walletModel.wallet else {
            throw Error.walletNotFound
        }

        let privateKey = try WalletManager.default.exportPrivateKey(wallet: wallet, password: password)
        guard let signed = try EthereumMessageSigner().sign(message: messageData, privateKey: privateKey) else {
            throw Error.signMessageFailed
        }
        return signed
    }

    public static func signPersonal(message: String, password: String) throws -> String {
        let messageData = Data.fromHex(message) ?? Data()
        let walletModel = AppModel.current.currentWallet!
        guard let wallet = walletModel.wallet else {
            throw Error.walletNotFound
        }

        let privateKey = try WalletManager.default.exportPrivateKey(wallet: wallet, password: password)
        guard let signed = try EthereumMessageSigner().signPersonalMessage(message: messageData, privateKey: privateKey) else {
            throw Error.signMessageFailed
        }
        return signed
    }
}
