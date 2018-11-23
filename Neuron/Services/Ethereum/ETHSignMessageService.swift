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
    enum Error: Swift.Error {
        case walletIsNull
        case privateKeyIsNull
        case signMessageFailed
    }

    public static func sign(message: String, password: String, completion: @escaping (SignMessageResult<String>) -> Void) {
        let messageData = Data.fromHex(message) ?? Data()
        let walletModel = AppModel.current.currentWallet!
        guard let wallet = walletModel.wallet else {
            completion(SignMessageResult.error(Error.walletIsNull))
            return
        }
        DispatchQueue.global().async {
            do {
                let privateKey = try WalletManager.default.exportPrivateKey(wallet: wallet, password: password)
                guard let signed = try EthereumMessageSigner().sign(message: messageData, privateKey: privateKey) else {
                    throw Error.signMessageFailed
                }
                DispatchQueue.main.async {
                    completion(SignMessageResult.success(signed))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(SignMessageResult.error(error))
                }
            }
        }
    }

    public static func signPersonal(message: String, password: String, completion: @escaping (SignMessageResult<String>) -> Void) {
        let messageData = Data.fromHex(message) ?? Data()
        let walletModel = AppModel.current.currentWallet!
        guard let wallet = walletModel.wallet else {
            completion(SignMessageResult.error(Error.walletIsNull))
            return
        }
        DispatchQueue.global().async {
            do {
                let privateKey = try WalletManager.default.exportPrivateKey(wallet: wallet, password: password)
                guard let signed = try EthereumMessageSigner().signPersonalMessage(message: messageData, privateKey: privateKey) else {
                    throw Error.signMessageFailed
                }
                DispatchQueue.main.async {
                    completion(SignMessageResult.success(signed))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(SignMessageResult.error(error))
                }
            }
        }
    }
}
