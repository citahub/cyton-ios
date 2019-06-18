//
//  BigUIntExtensionTests.swift
//  CytonTests
//
//  Created by James Chen on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
import BigInt
@testable import Cyton

class BigUIntExtensionTests: XCTestCase {
    func testToWei() {
        XCTAssertEqual(
            BigUInt(1),
            BigUInt(1).toWei(from: .wei)
        )

        XCTAssertEqual(
            BigUInt("1000000000"),
            BigUInt(1).toWei(from: .gwei)
        )

        XCTAssertEqual(
            BigUInt("1000000000000000000"),
            BigUInt(1).toWei(from: .ether)
        )
    }

    func testToGwei() {
        XCTAssertEqual(
            BigUInt(1),
            BigUInt("1000000000").toGwei(from: .wei)
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("10000").toGwei(from: .wei)
        )

        XCTAssertEqual(
            BigUInt(1),
            BigUInt(1).toGwei(from: .gwei)
        )

        XCTAssertEqual(
            BigUInt("1000000000"),
            BigUInt(1).toGwei(from: .ether)
        )
    }

    func testToEther() {
        XCTAssertEqual(
            BigUInt(1),
            BigUInt("1000000000000000000").toEther(from: .wei)
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("10000").toEther(from: .wei)
        )

        XCTAssertEqual(
            BigUInt(1),
            BigUInt("1000000000").toEther(from: .gwei)
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("10000").toEther(from: .gwei)
        )

        XCTAssertEqual(
            BigUInt(1),
            BigUInt(1).toEther(from: .ether)
        )
    }

    func testToQuota() {
        XCTAssertEqual(
            BigUInt("1000000000000000000"),
            BigUInt(1).toQuota()
        )
    }

    func testFromQuota() {
        XCTAssertEqual(
            BigUInt(1),
            BigUInt("1000000000000000000").fromQuota()
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("1000000000").fromQuota()
        )
    }

    func testStringToBigUInt() {
        XCTAssertEqual(BigUInt(string: "96016"), 96016)
        XCTAssertEqual(BigUInt(string: "0x96016"), 614422)
    }

    func testAmountTextToBigUInt() {
        XCTAssertEqual(BigUInt.parseToBigUInt("1.23", 4), 12_300)
        XCTAssertEqual(BigUInt.parseToBigUInt("0.00045", 18), 450_000_000_000_000)
        XCTAssertEqual(BigUInt.parseToBigUInt("1.23", 2), 123)
        XCTAssertEqual(BigUInt.parseToBigUInt("1.2344", 2), 123)
        XCTAssertEqual(BigUInt.parseToBigUInt("1.003", 2), 100)
    }

    func testBigUIntToAmountText() {
        XCTAssertEqual(BigUInt.parseToBigUInt("0.00032", 18).toDecimalNumber(18).formatterToString(18), "0.00032")
        XCTAssertEqual(BigUInt.parseToBigUInt("0.000000089999", 18).toDecimalNumber(18).formatterToString(18), "0.000000089999")
        XCTAssertEqual(BigUInt.parseToBigUInt("0.000000089999", 18).toAmountText(18), "0.00000008")
        XCTAssertEqual(BigUInt.parseToBigUInt("0.00000000000234", 18).toAmountText(18), "2.34e-12")
        XCTAssertEqual(BigUInt.parseToBigUInt("104.0040023089999", 18).toAmountText(18), "104.0040023")
    }

    func testBigUIntToDouble() {
        XCTAssertEqual(BigUInt.parseToBigUInt("0.00032", 18).toDouble(18), 0.00032)
        XCTAssertEqual(BigUInt.parseToBigUInt("0.000000089999", 18).toDouble(18), 0.000000089999)
        XCTAssertEqual(BigUInt.parseToBigUInt("2435.000000089999", 18).toDouble(18), 2435.000000089999)
        XCTAssertEqual(BigUInt.parseToBigUInt("2435.1234", 18).toDouble(18), 2435.1234)
    }
}
