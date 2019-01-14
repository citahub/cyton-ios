//
//  DoubleExtensionTests.swift
//  CytonTests
//
//  Created by 晨风 on 2018/11/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
import BigInt
@testable import Cyton

class DoubleExtensionTests: XCTestCase {
    func testClean() {
        XCTAssertEqual(0.001000.trailingZerosTrimmed, "0.001")
        XCTAssertEqual(2233.001000.trailingZerosTrimmed, "2233.001")
        XCTAssertEqual(2233.0010010.trailingZerosTrimmed, "2233.001001")
    }
}
