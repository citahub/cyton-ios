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
        config.encryptionKey = getEncryptionKey()
        /**
         *  设置可以在后台应用刷新中使用 Realm
         *  注意：以下的操作其实是关闭了 Realm 文件的 NSFileProtection 属性加密功能，将文件保护属性降级为一个不太严格的、允许即使在设备锁定时都可以访问文件的属性
         */
        // 禁用此目录的文件保护
        let folderPath = config.fileURL?.deletingLastPathComponent().path
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath!)
        Realm.Configuration.defaultConfiguration = config
    }
}

private extension RealmHelper {
    //realm encryption key
    static func getEncryptionKey() -> Data {
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "org.nervos.Neuron"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        // First check in the keychain for an existing key
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]
        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! Data
        }
        // No pre-existing key from this application, so generate a new one
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")
        // Store the key in the keychain
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData
        ]
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        return keyData as Data
    }

    static var migrationBlock: MigrationBlock {
        return { migration, oldSchemaVersion in
            if oldSchemaVersion < schemaVersion {
            }
        }
    }
}
