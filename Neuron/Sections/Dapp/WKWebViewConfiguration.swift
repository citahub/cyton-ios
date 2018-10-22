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

    static func make(for server: DAppServer, in messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let appModel = WalletRealmTool.getCurrentAppModel()
        let walletModel = appModel.currentWallet!
        var accounts: [String] = []
        appModel.wallets.forEach { (model) in
            accounts.append(model.address)
        }

        var js = ""
        if let neuronPath = Bundle.main.path(forResource: "neuron", ofType: "js") {
            do {
                js += try String(contentsOfFile: neuronPath)
            } catch { }
        }

        js += """
             const addressHex = "\(walletModel.address)";
             const rpcURL = "\(server.rpcUrl)";
             const chainID = "\(server.chainID)";
             const accounts = "\(accounts.joined(separator: ","))"
             """
        if let initPath = Bundle.main.path(forResource: "init", ofType: "js") {
            do {
                js += try String(contentsOfFile: initPath)
            } catch { }
        }
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.add(messageHandler, name: Method.signTransaction.rawValue)
        config.userContentController.add(messageHandler, name: Method.signPersonalMessage.rawValue)
        config.userContentController.add(messageHandler, name: Method.signMessage.rawValue)
        config.userContentController.add(messageHandler, name: Method.signTypedMessage.rawValue)
        config.userContentController.addUserScript(userScript)
        config.preferences.javaScriptEnabled = true
        return config
    }
}