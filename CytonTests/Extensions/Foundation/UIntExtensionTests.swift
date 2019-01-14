//
//  UIntExtensionTests.swift
//  CytonTests
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Cyton

class UIntExtensionTests: XCTestCase {
    func testFromHex() {
        XCTAssertEqual(UInt.fromHex("0xfff"), 4095)
        XCTAssertEqual(UInt.fromHex("8b9"), 2233)
        XCTAssertEqual(UInt.fromHex("400"), 1024)
        XCTAssertEqual(UInt.fromHex("zzz"), 0)
    }
}
