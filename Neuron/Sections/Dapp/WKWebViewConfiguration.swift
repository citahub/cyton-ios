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
        return config
    }
}
