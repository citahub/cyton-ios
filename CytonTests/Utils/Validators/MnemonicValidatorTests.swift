//
//  MnemonicValidatorTests.swift
//  CytonTests
//
//  Created by XiaoLu on 2018/11/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Cyton

class MnemonicValidatorTests: XCTestCase {
    func testEmptyMnemonic() {
        guard case .invalid(_) = MnemonicValidator.validate(mnemonic: " ") else {
            return XCTFail("Empty Mnemonic not checked")
        }
    }

    func testInvalidLengthMnemonic() {
        let mnemonics = [
            "witch collapse practice feed shame open despair creek road again ice",
            "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal",
            "choose bench pulse swift mosquito around subject pigeon poverty crystal soccer picture burger spread output select sun craft enroll ozone"
        ]
        mnemonics.forEach { menmonic in
            guard case .invalid(_) = MnemonicValidator.validate(mnemonic: menmonic) else {
                return XCTFail("Mnemonic with invalid length not checked: \(menmonic)")
            }
        }
    }

    func testValidMnemonic() {
        let mnemonics = [
            "witch collapse practice feed shame open despair creek road again ice least",
            "apology check reform capable either minimum regret piano space shallow valve figure express flame provide",
            "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will",
            "choose bench pulse swift mosquito around subject pigeon poverty crystal soccer picture burger spread output select sun craft enroll ozone able",
            "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic bless"
        ]
        mnemonics.forEach { menmonic in
            guard case .valid = MnemonicValidator.validate(mnemonic: menmonic) else {
                return XCTFail("Mnemonic valid not checked: \(menmonic)")
            }
        }
    }
}
