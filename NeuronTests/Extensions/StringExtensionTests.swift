//
//  StringExtensionTests.swift
//  NeuronTests
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Neuron

class StringExtensionTests: XCTestCase {
    func testHexValue() {
        XCTAssertEqual("0xfff".hexValue, 4095)
        XCTAssertEqual("8b9".hexValue, 2233)
        XCTAssertEqual("400".hexValue, 1024)
        XCTAssertEqual("zzz".hexValue, 0)
    }
}
