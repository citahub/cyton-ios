//
//  WalletManagerTests.swift
//  CytonTests
//
//  Created by James Chen on 2018/10/19.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
@testable import Cyton

class WalletManagerTests: XCTestCase {
    let keyDirectory =  FileManager.default.temporaryDirectory.appendingPathComponent("KeystoreTests")
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
        let wallet = try! walletManager.importMnemonic(mnemonic: mnemonic, password: "password")
        XCTAssertEqual(wallet.address, address)
        let exported = try! walletManager.exportPrivateKey(wallet: wallet, password: "password")
        XCTAssertEqual(exported, privateKey)
    }

    func testImportInvalidMnemonic() throws {
        XCTAssertThrowsError(try walletManager.importMnemonic(mnemonic: "abc", password: "password"))
        XCTAssertThrowsError(try walletManager.importMnemonic(mnemonic: " " + mnemonic + " ", password: "password"))
    }

    func testImportAndExportPrivateKey() throws {
        let wallet = try! walletManager.importPrivateKey(privateKey: privateKey, password: "password")
        let exported = try! walletManager.exportPrivateKey(wallet: wallet, password: "password")
        XCTAssertEqual(exported, privateKey)
    }

    func testImportInvalidPrivateKey() throws {
        XCTAssertThrowsError(try walletManager.importPrivateKey(privateKey: "abc", password: "password"))
    }

    func testExportAndImportKeystore() throws {
        let oldWallet = try! walletManager.importPrivateKey(privateKey: privateKey, password: "password")
        XCTAssertThrowsError(try walletManager.exportKeystore(wallet: oldWallet, password: "wrong password"))
        let exported = try! walletManager.exportKeystore(wallet: oldWallet, password: "password")
        XCTAssertNoThrow(try walletManager.deleteWallet(wallet: oldWallet, password: "password"))
        XCTAssertNoThrow(try walletManager.importKeystore(exported, password: "password"))
    }

    func testImportInvalidKeystore() throws {
        XCTAssertThrowsError(try walletManager.importKeystore("{}", password: "password"))
    }

    func testUpdatePassword() throws {
        let wallet = try! walletManager.importPrivateKey(privateKey: privateKey, password: "password")
        XCTAssertTrue(walletManager.verifyPassword(wallet: wallet, password: "password"))
        XCTAssertThrowsError(try walletManager.updatePassword(wallet: wallet, password: "wrong old password", newPassword: "new password"))
        XCTAssertNoThrow(try walletManager.updatePassword(wallet: wallet, password: "password", newPassword: "new password"))
        XCTAssertTrue(walletManager.verifyPassword(wallet: wallet, password: "new password"))
        XCTAssertFalse(walletManager.verifyPassword(wallet: wallet, password: "password"))
    }

    func testDeleteWallet() throws {
        let wallet = try! walletManager.importPrivateKey(privateKey: privateKey, password: "password")
        XCTAssertThrowsError(try walletManager.deleteWallet(wallet: wallet, password: "wrong password"))
        XCTAssertNoThrow(try walletManager.deleteWallet(wallet: wallet, password: "password"))
    }

    func testWalletExists() throws {
        XCTAssertFalse(walletManager.walletExists(address: address))
        _ = try! walletManager.importPrivateKey(privateKey: privateKey, password: "password")
        XCTAssertTrue(walletManager.walletExists(address: address))
    }

    func testVerifyPassword() throws {
        let wallet = try! walletManager.importPrivateKey(privateKey: privateKey, password: "password")
        XCTAssertTrue(walletManager.verifyPassword(wallet: wallet, password: "password"))
        XCTAssertFalse(walletManager.verifyPassword(wallet: wallet, password: "wrong password"))
    }

    func testGenerate12WordsMnemonic() {
        let mnemonic = WalletManager.generateMnemonic()
        XCTAssertEqual(mnemonic.split(separator: " ").count, 12)
    }
}
