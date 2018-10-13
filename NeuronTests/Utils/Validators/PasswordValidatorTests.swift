//
//  PasswordValidatorTests.swift
//  NeuronTests
//
//  Created by James Chen on 2018/10/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Neuron

class PasswordValidatorTests: XCTestCase {
    func testEmptyPassword() {
        guard case .invalid(reason: _) = PasswordValidator.validate(password: "") else {
            return XCTFail()
        }
    }
}
