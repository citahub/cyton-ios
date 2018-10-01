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

    //使用默认的文件名和路径
    static var sharedInstance = try! Realm()
    /// 版本号
    private static var schemaVersion: UInt64 = 1
    // MARK: 初始化 Realm
    /// 初始化进过加密的 Realm， 加密过的 Realm 只会带来很少的额外资源占用（通常最多只会比平常慢10%）
    static func initEncryptionRealm() {
        // 打开加密文件
        // Open the encrypted Realm file
        var config = Realm.Configuration()
        config.schemaVersion = schemaVersion
        config.encryptionKey = getKey() as Data
        //data migration
        let folderPath = config.fileURL?.deletingLastPathComponent().path
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < schemaVersion {

            }
        }
        /**
         *  设置可以在后台应用刷新中使用 Realm
         *  注意：以下的操作其实是关闭了 Realm 文件的 NSFileProtection 属性加密功能，将文件保护属性降级为一个不太严格的、允许即使在设备锁定时都可以访问文件的属性
         */
        // 禁用此目录的文件保护
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath!)
        // 将这个配置应用到默认的 Realm 数据库当中
        Realm.Configuration.defaultConfiguration = config
    }
    //realm encryption key
    private static func getKey() -> NSData {
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
            return dataTypeRef as! NSData
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
        return keyData
    }
}
