//
//  DAppDataHandle.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import WebKit

struct DAppDataHandle {
    static func fromMessage(message: WKScriptMessage) throws -> DAppCommonModel {
        let decoder = JSONDecoder()
        guard let body = message.body as? [String: AnyObject] else {
            throw DAppAction.Error.emptyTX
        }
        let objectData = try! JSONSerialization.data(withJSONObject: body, options: .init(rawValue: 0))
        let objectModel = try! decoder.decode(DAppCommonModel.self, from: objectData)
        return objectModel
    }

    static func fromTitleBarMessage(message: WKScriptMessage) -> TitleBarModel {
        let decoder = JSONDecoder()
        let body = message.body as! [String: String]
        let objectJson = body["body"]!
        let objectModel = try! decoder.decode(TitleBarModel.self, from: objectJson.data(using: String.Encoding.utf8)!)
        return objectModel
    }
}
