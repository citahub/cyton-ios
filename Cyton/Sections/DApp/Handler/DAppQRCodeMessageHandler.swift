//
//  DAppQRCodeMessageHandler.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import WebKit

class DAppQRCodeMessageHandler: DAppNativeMessageHandler, QRCodeViewControllerDelegate {
    override var messageNames: [String] {
        return ["scanCode"]
    }

    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        super.userContentController(userContentController, didReceive: message)
        let controller = QRCodeViewController()
        controller.delegate = self
        message.webView?.viewController?.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - QRCodeViewControllerDelegate
    func didBackQRCodeMessage(codeResult: String) {
        callback(result: .success(["result": codeResult]))
    }

    func qrcodeReaderDidCancel() {
        callback(result: .fail(-1, "Common.Connection.UserCancel".localized()))
    }
}
