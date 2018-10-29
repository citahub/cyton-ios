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
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        guard let wallet = WalletTool.wallet(for: walletModel.address) else {
            completion(SignMessageResult.error(Error.walletIsNull))
            return
        }
        DispatchQueue.global().async {
            guard case .succeed(result: let privateKey) = WalletTool.exportPrivateKey(wallet: wallet, password: password) else {
                DispatchQueue.main.async {
                    completion(SignMessageResult.error(Error.privateKeyIsNull))
                }
                return
            }
            guard let signed = try! EthereumMessageSigner().sign(message: messageData, privateKey: privateKey) else {
                DispatchQueue.main.async {
                    completion(SignMessageResult.error(Error.signMessageFailed))
                }
                return
            }
            DispatchQueue.main.async {
                completion(SignMessageResult.success(signed))
            }
        }
    }

    public static func signPersonal(message: String, password: String, completion: @escaping (SignMessageResult<String>) -> Void) {
        let messageData = Data.fromHex(message) ?? Data()
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        guard let wallet = WalletTool.wallet(for: walletModel.address) else {
            completion(SignMessageResult.error(Error.walletIsNull))
            return
        }
        DispatchQueue.global().async {
            guard case .succeed(result: let privateKey) = WalletTool.exportPrivateKey(wallet: wallet, password: password) else {
                DispatchQueue.main.async {
                    completion(SignMessageResult.error(Error.privateKeyIsNull))
                }
                return
            }
            guard let signed = try! EthereumMessageSigner().signPersonalMessage(message: messageData, privateKey: privateKey) else {
                DispatchQueue.main.async {
                    completion(SignMessageResult.error(Error.signMessageFailed))
                }
                return
            }
            DispatchQueue.main.async {
                completion(SignMessageResult.success(signed))
            }
        }
    }
}
