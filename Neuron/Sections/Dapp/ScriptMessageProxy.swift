//
//  ScriptMessageProxy.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import WebKit

final class ScriptMessageProxy: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
