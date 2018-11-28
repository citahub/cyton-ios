//
//  MnemonicValidator.swift
//  Neuron
//
//  Created by XiaoLu on 2018/11/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

struct MnemonicValidator {
    enum Result {
        case valid
        case invalid(String)
    }

    static func validate(mnemonic: String) -> Result {
        if mnemonic.isEmpty {
            return .invalid("WalletManager.Error.emptyMnemonic".localized())
        }

        let wordList = mnemonic.components(separatedBy: " ")
        guard wordList.count >= 12 && wordList.count % 4 == 0 else {
            return .invalid("WalletManager.Error.invalidMnemonic".localized())
        }

        return .valid
    }
}
