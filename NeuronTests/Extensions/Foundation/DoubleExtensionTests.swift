//
//  DoubleExtensionTests.swift
//  NeuronTests
//
//  Created by 晨风 on 2018/11/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
import BigInt
@testable import Neuron

class DoubleExtensionTests: XCTestCase {
    func testClean() {
        XCTAssertEqual(0.001000.trailingZerosTrimmed, "0.001")
        XCTAssertEqual(2233.001000.trailingZerosTrimmed, "2233.001")
        XCTAssertEqual(2233.0010010.trailingZerosTrimmed, "2233.001001")
    }

    func testToAmount() {
        XCTAssertEqual(3.1415926.toAmount(18), BigUInt("3141592600000000000")!)
    }

    func testFromAmount() {
        XCTAssertEqual(Double.fromAmount(BigUInt("3141592600000000000")!, decimals: 18), 3.1415926)
    }

    func testGweiToWei() {
        XCTAssertEqual(
            20500000000,
            20.5.gweiToWei()
        )
    }
}
