//
//  UIStoryboardExtensionTests.swift
//  CytonTests
//
//  Created by James Chen on 2018/10/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Cyton

class UIStoryboardExtensionTests: XCTestCase {
    func testCapitalized() {
        XCTAssertEqual(UIStoryboard.Name.authentication.capitalized, "Authentication")
        XCTAssertEqual(UIStoryboard.Name.switchWallet.capitalized, "SwitchWallet")
        XCTAssertEqual(UIStoryboard.Name.main.capitalized, "Main")
    }
}
