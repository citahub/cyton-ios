//
//  BigUIntExtensionTests.swift
//  NeuronTests
//
//  Created by James Chen on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
import BigInt
@testable import Neuron

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
            BigUInt("1000000000")!.toGwei(from: .wei)
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("10000")!.toGwei(from: .wei)
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
            BigUInt("1000000000000000000")!.toEther(from: .wei)
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("10000")!.toEther(from: .wei)
        )

        XCTAssertEqual(
            BigUInt(1),
            BigUInt("1000000000")!.toEther(from: .gwei)
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("10000")!.toEther(from: .gwei)
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
            BigUInt("1000000000000000000")!.fromQuota()
        )
        XCTAssertEqual(
            BigUInt(0),
            BigUInt("1000000000")!.fromQuota()
        )
    }

    func testWeiToGwei() {
        XCTAssertEqual(
            20.5,
            BigUInt("20500000000")!.weiToGwei()
        )
    }
}
