//
//  WalletManagerTests.swift
//  NeuronTests
//
//  Created by James Chen on 2018/10/19.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Neuron

class WalletManagerTests: XCTestCase {
    var keyDirectory: URL!

    override func setUp() {
        super.setUp()

        keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreTests")
        try? FileManager.default.removeItem(at: keyDirectory)
        try? FileManager.default.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    func testExportPrivateKeyFromKeyWallet() throws {
        /* TODO
        guard case .succeed(let exported) = WalletManager.exportPrivateKey(wallet: keyWallet, password: "password") else {
            return XCTFail("Export fail")
        }
        XCTAssertEqual(Data.fromHex(exported), privateKey.data)
        */
    }

    func testExportPrivateKeyFromHDWallet() throws {
        /*
        let keyStore = try KeyStore(keyDirectory: keyDirectory)
        let hdWallet = try keyStore.import(
            mnemonic: "begin auction word young address dawn chief maid brave arrive copy process",
            encryptPassword: "password",
            derivationPath: DerivationPath(WalletManager.defaultDerivationPath)!
        )
        guard case .succeed(let exported) = WalletManager.exportPrivateKey(wallet: hdWallet, password: "password") else {
            return XCTFail("Export fail")
        }
        XCTAssertEqual(exported, "6e2c8766538873002c638137de5d2270a07b413468ae125ec2751526ffefcffa")
        */
    }

    func testGenerate12WordsMnemonic() {
        let mnemonic = WalletManager.generateMnemonic()
        XCTAssertEqual(mnemonic.split(separator: " ").count, 12)
    }
}
