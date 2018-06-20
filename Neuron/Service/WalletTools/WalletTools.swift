//
//  WalletTools.swift
//  KKWallet
//
//  Created by 曹茂鑫 on 2018/5/17.
//  Copyright © 2018年 Caomaoxin. All rights reserved.
//

import UIKit
import SwiftyJSON
import TrustKeystore
import Result


class WalletTools: NSObject {

    static let defaultDerivationPath = "m/44'/60'/0'/0/0"
    typealias ImportResultCallback = (ImportResult<Account>) -> Void
    typealias GenerateMnemonicCallback = (String) -> Void
    
    static let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0]
    static let keysDirectory: URL = URL(fileURLWithPath: documentDir + "/keystore")
    static let keyStore = try? KeyStore(keyDirectory: keysDirectory)
    //创建钱包
    @available(iOS 10.0, *)
    static func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }
    
    static func createAccout(password: String) -> Account {
        let account = try! keyStore?.createAccount(password: password, type: .hierarchicalDeterministicWallet)
        return account!
    }
    
    /// 生成12位助记词
    ///
    /// - Parameter completion: 回调
    static func generateMnemonic(completion: @escaping GenerateMnemonicCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let mnemonic = Mnemonic.generate(strength: 128)
            let words = mnemonic.components(separatedBy: " ")
            var repeateWordsDetector = [String]()
            for word in words {
                if repeateWordsDetector.contains(word){
                    generateMnemonic(completion: completion)
                    return
                }
                repeateWordsDetector.append(word)
            }
            DispatchQueue.main.async {
                completion(mnemonic)
            }
        }
    }
    
    /// 导入钱包
    ///
    /// - Parameters:
    ///   - importType: 导入类型
    ///   - completion: 导入结果回调
    static func importWallet(with importType: ImportType, completion: @escaping ImportResultCallback) {
        switch importType {
        case .keyStore(let json, let password):
            importJSONKeyAsync(jsonKey: json, password: password, completion: completion)
        case .privateKey(let privateKey, let password):
            importPrivateKeyAsync(privateKey: privateKey, password: password, completion: completion)
        case .mnemonic(let mnemonic, let password, let derivationPath):
            importMnemonicAsync(mnemonic: mnemonic, password: password, devirationPath: derivationPath, completion: completion)
        }
    }
    
    /// 异步导入助记词钱包
    ///
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - password: 钱包密码
    ///   - devirationPath: devirationPath
    ///   - completion: 导入结果回调
    static func importMnemonicAsync(mnemonic: String, password: String, devirationPath: String, completion: @escaping ImportResultCallback){
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importMnemonic(mnemonic: mnemonic, password: password, devirationPath: devirationPath)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }
    
    /// 导入助记词钱包
    ///
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - password: 钱包密码
    ///   - devirationPath: devirationPath
    ///   - completion: 导入结果回调
    static func importMnemonic(mnemonic: String, password: String, devirationPath: String) -> ImportResult<Account> {
        guard (keyStore != nil) else {
            return ImportResult.failed(error: ImportError.openKeyStoreFailed, errorMessage: "JSON密钥导入失败")
        }
        do {
            let account = try keyStore!.import(mnemonic: mnemonic, passphrase: "", derivationPath: devirationPath, encryptPassword: password)
            return ImportResult.succeed(result: account)
        } catch {
            switch error {
            case KeyStore.Error.accountAlreadyExists:
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "账户已经存在")
            case DecryptError.invalidPassword:
                return ImportResult.failed(error: ImportError.wrongPassword, errorMessage: "密码错误")
            case KeyStore.Error.invalidMnemonic:
                return ImportResult.failed(error: ImportError.invalidateMnemonic, errorMessage: "无效的助记词")
            default:
                return ImportResult.failed(error: error, errorMessage: "钱包导入失败")
            }
        }
    }
    
    /// 异步导入JSON密钥
    ///
    /// - Parameters:
    ///   - jsonKey: json密钥
    ///   - password: 密码
    ///   - completion: 回调
    static func importJSONKeyAsync(jsonKey: String, password: String, completion: @escaping ImportResultCallback){
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importWalletInJSON(json: jsonKey, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }
    
    /// 通过JSON形式的密钥导入钱包
    ///
    /// - Parameters:
    ///   - json: json密钥
    ///   - password: 密码
    /// - Returns: 导入结果
    static func importWalletInJSON(json: String?, password: String) -> ImportResult<Account> {
        
        guard let data = json?.data(using: .utf8) else {
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "无效的JSON秘钥")
        }
        guard let keyStore = keyStore else {
            return ImportResult.failed(error: ImportError.openKeyStoreFailed, errorMessage: "JSON密钥导入失败")
        }
        
        do {
            let account = try keyStore.import(json: data, password: password, newPassword: password)
            return ImportResult.succeed(result: account)
        } catch {
            switch error {
            case KeyStore.Error.accountAlreadyExists:
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "账户已经存在")
            default:
                return ImportResult.failed(error: error, errorMessage: "钱包导入失败")
            }
        }
    }
    
    /// 使用私钥异步导入钱包
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - password: 钱包密码
    /// - Returns: ImportResult
    static func importPrivateKeyAsync(privateKey: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importPrivateKey(privateKey: privateKey, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }
    
    /// 使用私钥导入钱包
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - password: 钱包密码
    /// - Returns: ImportResult
    static func importPrivateKey(privateKey: String, password: String) -> ImportResult<Account> {
        let convertResult = convertPrivateKeyToJSON(hexPrivateKey: privateKey, password: password)
        switch convertResult {
        case .succeed(let jsonResult):
            return importWalletInJSON(json: jsonResult,password: password)
            
        case .failed(let error, let errorMessage):
            return ImportResult.failed(error: error, errorMessage: errorMessage)
        }
    }
    
    /// 私钥和密码转换为JSON形式的密钥
    ///
    /// - Parameters:
    ///   - hexPrivateKey: hex形式的私钥
    ///   - password: 钱包密码
    /// - Returns: ImportResult
    public static func convertPrivateKeyToJSON(hexPrivateKey: String, password: String) -> ImportResult<String> {
        guard let data = Data(hexString: hexPrivateKey) else {
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "导入私钥失败")
        }
        do {
            let key = try KeystoreKey(password: password, key: data)
            let data = try JSONEncoder().encode(key)
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let json = JSON(dict)
            let rawJson = json.rawString()
            if let rawJson = rawJson {
                return ImportResult.succeed(result: rawJson)
            }
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "导入私钥失败")
        } catch {
            return ImportResult.failed(error: error, errorMessage: "导入私钥失败")
        }
    }
    
    static func exportPrivateKey(account: Account,password:String) -> ImportResult<String?> {
        do {
            let privateKey = try keyStore?.exportPrivateKey(account: account, password: password)
            return ImportResult.succeed(result: privateKey?.toHexString())
        } catch {
            return ImportResult.failed(error:error,errorMessage:"导出私钥失败")
        }
    }
    
}
