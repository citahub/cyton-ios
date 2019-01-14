//
//  WalletNameValidatorTests.swift
//  CytonTests
//
//  Created by XiaoLu on 2018/10/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Cyton

class WalletNameValidatorTests: XCTestCase {
    func testEmptyWalletName() {
        guard case .invalid(_) = WalletNameValidator.validate(walletName: "") else {
            return XCTFail("Empty wallet name not checked")
        }
    }

    func testOnlySpacesWalletName() {
        guard case .invalid(_) = WalletNameValidator.validate(walletName: "  ") else {
            return XCTFail("Only spaces wallet name not checked")
        }
    }

    func testWalletNameLength() {
        guard case .invalid(_) = WalletNameValidator.validate(walletName: "abcdefghijklmnop") else {
            return XCTFail("Wallet name length not checked")
        }
    }

    func testWalletNameExistence() {
        let appModel = AppModel.current
        let walletModel = WalletModel()
        walletModel.name = "ETH Wallet"
        walletModel.address = "0x6782CdeF6A4A056d412775EE6081d32B2bf90287"
        let existence = appModel.wallets.contains(where: {$0.address == walletModel.address})
        let realm = try! Realm()
        try! realm.write {
            if !existence {
                appModel.wallets.append(walletModel)
            }
            realm.add(appModel)
        }
        guard case .invalid(_) = WalletNameValidator.validate(walletName: "ETH Wallet") else {
            return XCTFail("Wallet name existence not checked")
        }
    }
}
