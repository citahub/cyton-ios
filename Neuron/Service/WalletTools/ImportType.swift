//
//  ImportType.swift
//  VIPWallet
//
//  Created by Ryan on 2018/4/8.
//  Copyright © 2018年 Qingkong. All rights reserved.
//

import Foundation

enum ImportType {
    case keyStore(json: String, password: String)
    case privateKey(privateKey: String, password: String)
    case mnemonic(mnemonic: String, password: String, derivationPath: String)
}
