//
//  PasswordValidatorTests.swift
//  CytonTests
//
//  Created by James Chen on 2018/10/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Cyton

class PasswordValidatorTests: XCTestCase {
    func testEmptyPassword() {
        guard case .invalid(reason: _) = PasswordValidator.validate(password: "") else {
            return XCTFail("Empty password not checked")
        }
    }

    func testPasswordLength() {
        guard case .invalid(reason: _) = PasswordValidator.validate(password: "Abcd123") else {
            return XCTFail("Password length not checked")
        }
    }

    func testPasswordComplexity() {
        [
            "Abcdefgh",
            "abcdefg1",
            "~abcdefg",
            "abcdefg*"
        ].forEach { password in
            guard case .invalid(reason: _) = PasswordValidator.validate(password: password) else {
                return XCTFail("Password complexity not checked")
            }
        }
    }

    func testValidPasswords() {
        [
            "Abcdefg1",
            "abcdef1*",
            "~abcdefG",
            "aBcdefg*"
        ].forEach { password in
            guard case .valid = PasswordValidator.validate(password: password) else {
                return XCTFail("Password valid not checked")
            }
        }
    }
}
