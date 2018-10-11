//
//  RealmHelpers.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/8.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    static var sharedInstance = try! Realm()
    private static var schemaVersion: UInt64 = 2

    static func configRealm() {
        var config = Realm.Configuration()
        config.schemaVersion = schemaVersion
        config.migrationBlock = migrationBlock

        if schemaVersion >= 2, let encryptionKey = getEncryptionKey() {
            removeEncrptionFromRealm(key: encryptionKey)
            deleteEncryptionKeyFromKeychain()
        }

        Realm.Configuration.defaultConfiguration = config
    }
}

private extension RealmHelper {
    static func getEncryptionKey() -> Data? {
        let keychainIdentifier = "org.nervos.Neuron"
        let query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifier.data(using: .utf8, allowLossyConversion: false) as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }

        return nil
    }

    static func deleteEncryptionKeyFromKeychain() {
        // TODO
    }

    static func removeEncrptionFromRealm(key: Data) {
        autoreleasepool {
            var config = Realm.Configuration()
            config.schemaVersion = schemaVersion
            config.migrationBlock = migrationBlock
            config.encryptionKey = key

            let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("temp.realm")
            let realm = try! Realm(configuration: config)
            try! realm.writeCopy(toFile: tempUrl, encryptionKey: nil)
            try! FileManager.default.removeItem(at: config.fileURL!)
            try! FileManager.default.moveItem(at: tempUrl, to: config.fileURL!)
        }
    }

    static var migrationBlock: MigrationBlock {
        return { migration, oldSchemaVersion in
            if oldSchemaVersion < schemaVersion {
            }
        }
    }
}
