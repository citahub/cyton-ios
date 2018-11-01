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
    let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeystoreTests")
    var walletManager: WalletManager!

    let privateKey = "95ba839425d01128a08722aa68984ae5da4352fdba5d5c0cfdb8d9a355a264d2"
    let mnemonic = "come assume destroy crouch old original yard lamp diesel inform country lawn"
    let address = "0xfd4BB01f1fbF45A39e9E44a1B7f1310868599E0d"

    override func setUp() {
        super.setUp()

        try? FileManager.default.removeItem(at: keyDirectory)
        try? FileManager.default.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)

        walletManager = WalletManager(path: keyDirectory.path, fullPath: true)
    }

    func testImportMnemonic() throws {
        guard case .succeed(result: let wallet) = walletManager.importMnemonic(mnemonic: mnemonic, password: "password") else {
            return XCTFail("Import fail")
        }
        XCTAssertEqual(wallet.address, address)
        guard case .succeed(let exported) = walletManager.exportPrivateKey(wallet: wallet, password: "password") else {
            return XCTFail("Export fail")
        }
        XCTAssertEqual(exported, privateKey)
    }

    func testImportPrivateKey() throws {
        guard case .succeed(result: let wallet) = walletManager.importPrivateKey(privateKey: privateKey, password: "password") else {
            return XCTFail("Import fail")
        }
        guard case .succeed(let exported) = walletManager.exportPrivateKey(wallet: wallet, password: "password") else {
            return XCTFail("Export fail")
        }
        XCTAssertEqual(exported, privateKey)
    }

    func testVerifyPassword() throws {
        guard case .succeed(result: let wallet) = walletManager.importPrivateKey(privateKey: privateKey, password: "password") else {
            return XCTFail("Import fail")
        }
        XCTAssertTrue(walletManager.verifyPassword(wallet: wallet, password: "password"))
        XCTAssertFalse(walletManager.verifyPassword(wallet: wallet, password: "wrong password"))
    }

    func testUpdatePassword() throws {
        guard case .succeed(result: let wallet) = walletManager.importPrivateKey(privateKey: privateKey, password: "password") else {
            return XCTFail("Import fail")
        }
        XCTAssertTrue(walletManager.verifyPassword(wallet: wallet, password: "password"))
        XCTAssertThrowsError(try walletManager.updatePassword(wallet: wallet, password: "wrong old password", newPassword: "new password"))
        XCTAssertNoThrow(try walletManager.updatePassword(wallet: wallet, password: "password", newPassword: "new password"))
        XCTAssertTrue(walletManager.verifyPassword(wallet: wallet, password: "new password"))
        XCTAssertFalse(walletManager.verifyPassword(wallet: wallet, password: "password"))
    }

    func testGenerate12WordsMnemonic() {
        let mnemonic = WalletManager.generateMnemonic()
        XCTAssertEqual(mnemonic.split(separator: " ").count, 12)
    }
}
