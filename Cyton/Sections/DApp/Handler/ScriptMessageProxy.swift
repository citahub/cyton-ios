//
//  ScriptMessageProxy.swift
//  Cyton
//
//  Created by XiaoLu on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import WebKit

final class ScriptMessageProxy: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    var handlerBlock: ((WKScriptMessage) -> Void)?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    init(handlerBlock: @escaping (WKScriptMessage) -> Void) {
        self.handlerBlock = handlerBlock
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
        handlerBlock?(message)
    }
}

extension WKWebView {
    func addMessageHandler(name: String, handler: @escaping (WKScriptMessage) -> Void) {
        let messageProxy = ScriptMessageProxy(handlerBlock: handler)
        configuration.userContentController.add(messageProxy, name: name)
    }
}
