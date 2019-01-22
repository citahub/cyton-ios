//
//  DAppDataHandle.swift
//  Cyton
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
}
