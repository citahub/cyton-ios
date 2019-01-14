//
//  Method.swift
//  Cyton
//
//  Created by XiaoLu on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

enum Method: String, Decodable {
    case sendTransaction
    case signTransaction
    case signPersonalMessage
    case signMessage
    case signTypedMessage
    case unknown

    var rawValue: String {
        switch self {
        case .sendTransaction:
            return "sendTransaction"
        case .signTransaction:
            return "signTransaction"
        case .signPersonalMessage:
            return "signPersonalMessage"
        case .signMessage:
            return "signMessage"
        case .signTypedMessage:
            return "signTypedMessage"
        case .unknown:
            return "unknown"
        }
    }

    init(string: String) {
        self = Method(rawValue: string) ?? .unknown
    }
}
