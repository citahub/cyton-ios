//
//  ImportType.swift
//  Neuron
//
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation

enum ImportType {
    case keystore(keystore: String, password: String)
    case privateKey(privateKey: String, password: String)
    case mnemonic(mnemonic: String, password: String, derivationPath: String)
}
