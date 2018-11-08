//
//  DoubleExtensionTests.swift
//  NeuronTests
//
//  Created by 晨风 on 2018/11/8.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Neuron

class DoubleExtensionTests: XCTestCase {
    func testClean() {
        XCTAssertEqual(0.001000.clean, "0.001")
        XCTAssertEqual(2233.001000.clean, "2233.001")
        XCTAssertEqual(2233.0010010.clean, "2233.001001")
    }
}
