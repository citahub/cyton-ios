//
//  DAppNativeMessageHandler.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import WebKit

class DAppNativeMessageHandler: NSObject, WKScriptMessageHandler {
    enum Result {
        case success([String: Any])
        case fail(Int, String)
    }

    struct Callback: Decodable {
        let callback: String
    }

    var callback: String?
    weak var webView: WKWebView?
    var messageNames: [String] { return [] }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        webView = message.webView
        guard let data = try? JSONSerialization.data(withJSONObject: message.body, options: .prettyPrinted) else { return }
        callback = try? JSONDecoder().decode(Callback.self, from: data).callback
    }

    func callback(result: Result) {
        guard let callback = callback else { return }
        let resultDict: [String: Any]
        switch result {
        case .success(let info):
            resultDict = [
                "status": 1,
                "info": info
            ]
        case .fail(let code, let msg):
            resultDict = [
                "status": 0,
                "errorCode": code,
                "errorMsg": msg
            ]
        }
        self.callback(funcName: callback, result: resultDict)
    }

    func callback(funcName: String, result: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else { return }
        var string = String(bytes: data.bytes, encoding: .utf8) ?? ""
        string = string.replacingOccurrences(of: "\n", with: "")
        let js = "\(funcName)('\(string)')"
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }
}

extension WKWebView {
    func addNativeFunctionHandler(handler: DAppNativeMessageHandler) {
        for name in handler.messageNames {
            configuration.userContentController.add(handler, name: name)
        }
    }

    func addAllNativeFunctionHandler() {
        addNativeFunctionHandler(handler: DAppQRCodeMessageHandler())
        addNativeFunctionHandler(handler: DAppDeviceMotionMessageHandler())
        addNativeFunctionHandler(handler: DAppGyroscopeMessageHandler())
        addNativeFunctionHandler(handler: DAppPermissionsMessageHandler())
    }
}

extension UIResponder {
    var viewController: UIViewController? {
        if let controller = self as? UIViewController {
            return controller
        } else {
            return next?.viewController
        }
    }
}
