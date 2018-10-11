//
//  Method.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

enum Method: String {
    case sendTransaction
    case signTransaction
    case signPersonalMessage
    case signMessage
    case signTypedMessage
    case unknown

    init(string: String) {
        self = Method(rawValue: string) ?? .unknown
    }
}
