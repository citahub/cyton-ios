//
//  MnemonicValidatorTests.swift
//  NeuronTests
//
//  Created by XiaoLu on 2018/11/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Neuron

class MnemonicValidatorTests: XCTestCase {

    func testEmptyMnemonic() {
        guard case .invalid(_) = MnemonicValidator.validate(mnemonic: " ") else {
            return XCTFail("Empty Mnemonic not checked")
        }
    }

    func testInvalidMnemonic() {
        guard case .invalid(_) = MnemonicValidator.validate(mnemonic: "hard enrich void frown talk squirrel high sister raven today motion") else {
            return XCTFail("Empty Mnemonic not checked")
        }
    }

}
