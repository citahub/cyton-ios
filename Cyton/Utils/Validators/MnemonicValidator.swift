//
//  MnemonicValidator.swift
//  Cyton
//
//  Created by XiaoLu on 2018/11/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

/// Note: Only length is validated. Checksum and actual word dictionary lookup is skipped.
struct MnemonicValidator {
    enum Result {
        case valid
        case invalid(String)
    }

    static func validate(mnemonic: String) -> Result {
        if mnemonic.isEmpty {
            return .invalid("MnemonicValidator.emptyMnemonic".localized())
        }

        let wordList = mnemonic.components(separatedBy: " ")
        guard [12, 15, 18, 21, 24].contains(wordList.count) else {
            return .invalid("MnemonicValidator.invalidMnemonic".localized())
        }

        return .valid
    }
}
