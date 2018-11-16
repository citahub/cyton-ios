//
//  BigUIntExtensionTests.swift
//  NeuronTests
//
//  Created by 晨风 on 2018/11/15.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Neuron
import BigInt

class UIntExtensionTests: XCTestCase {
    func testFromHex() {
        XCTAssertEqual(BigUInt(string: "96016"), 96016)
        XCTAssertEqual(BigUInt(string: "0x96016"), 614422)
    }
}
