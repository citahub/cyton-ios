//
//  GasCalculatorTests.swift
//  CytonTests
//
//  Created by James Chen on 2018/11/07.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
import BigInt
@testable import Cyton

class GasCalculatorTests: XCTestCase {
    let doubleAccuracy = 0.0000001

    func testTxFee() {
        // Default gas limit is 21000
        XCTAssertEqual(
            Double("0.000084")!,
            GasCalculator.txFeeNatural(gasPrice: 4_000_000_000),
            accuracy: doubleAccuracy
        )

        XCTAssertEqual(
            Double("0.002")!,
            GasCalculator.txFeeNatural(gasPrice: 20_000_000_000, gasLimit: 100_000),
            accuracy: doubleAccuracy
        )

        XCTAssertEqual(
            Double("0.1005")!,
            GasCalculator.txFeeNatural(gasPrice: 100_000_000_000, gasLimit: 1_005_000),
            accuracy: doubleAccuracy
        )

        XCTAssertEqual(
            Double("6.0")!,
            GasCalculator.txFeeNatural(gasPrice: 1_000_000_000_000, gasLimit: 6_000_000),
            accuracy: doubleAccuracy
        )
    }

    func testGetPrice() {
        let expect = expectation(description: "Async get current gas price")
        var gasPrice = BigUInt(0)
        GasPriceFetcher().fetchGasPrice { price in
            gasPrice = price
            expect.fulfill()
        }
        waitForExpectations(timeout: 5)
        XCTAssert(gasPrice > 0)
    }

    func testInstance() {
        XCTAssertEqual(
            Double("6.0")!,
            GasCalculator(gasPrice: 1_000_000_000_000, gasLimit: 6_000_000).txFeeNatural,
            accuracy: doubleAccuracy
        )
    }

    func testTxFeePerformance() {
        measure {
            XCTAssertEqual(
                Double("6.0")!,
                GasCalculator.txFeeNatural(gasPrice: 1_000_000_000_000, gasLimit: 6_000_000),
                accuracy: doubleAccuracy
            )
        }
    }
}
