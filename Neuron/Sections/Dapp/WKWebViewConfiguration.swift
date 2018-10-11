//
//  WKWebViewConfiguration.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import WebKit

extension WKWebViewConfiguration {

    static func make(for server: DAppServer, address: String, in messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        var js = """
                const addressHex = "\(walletModel.address)";
                const rpcURL = "\(server.rpcUrl)";
                const chainID = "\(server.chainID)";
                """
        if let path = Bundle.main.path(forResource: "init", ofType: "js") {
            do {
                js += try String(contentsOfFile: path)
            } catch { }
        }

        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.add(messageHandler, name: Method.signTransaction.rawValue)
        config.userContentController.add(messageHandler, name: Method.signPersonalMessage.rawValue)
        config.userContentController.add(messageHandler, name: Method.signMessage.rawValue)
        config.userContentController.add(messageHandler, name: Method.signTypedMessage.rawValue)
        config.userContentController.addUserScript(userScript)
        return config
    }
}
