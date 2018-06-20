//
//  NeuronMacro.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

//主题颜色
let themeColor = "#2E46f0"
let lineColor = "#f1f1f1"



/// 屏幕高度
let ScreenH = UIScreen.main.bounds.height
/// 屏幕宽度
let ScreenW = UIScreen.main.bounds.width

//判断是不是iPhoneX
public func isiphoneX() -> Bool {
    
    if UIScreen.main.bounds.height == 812 {
        return true
    }else{
        return false
    }
}

//返回realm的加密key
func getKey() -> NSData {
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

//随机打乱数组
extension Array{
    public func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }
}

