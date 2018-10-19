//
//  WalletTool.swift
//  Neuron
//
//

import UIKit
import TrustKeystore
import TrustCore
import struct TrustCore.EthereumAddress
import Result

struct WalletTool {
    static let defaultDerivationPath = "m/44'/60'/0'/0/0"
    typealias ImportResultCallback = (ImportResult<Account>) -> Void
    typealias GenerateMnemonicCallback = (String) -> Void
    typealias ExportPrivateCallback = (ImportResult<String>) -> Void

    static let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0]
    static let keysDirectory: URL = URL(fileURLWithPath: documentDir + "/keystore")
    static let keyStore = try! KeyStore(keyDirectory: keysDirectory)

    static func wallet(for address: String) -> Wallet? {
        if let ethAddress = EthereumAddress(string: address) {
            return keyStore.wallets.first(where: { wallet in
                wallet.accounts[0].address.data == ethAddress.data
            })
        }
        return nil
    }

    static func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccount(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }

    static func createAccount(password: String) -> Account {
        let wallet = try! keyStore.createWallet(password: password, derivationPaths: [DerivationPath(defaultDerivationPath)!])
        return wallet.accounts[0]
    }

    /// 生成12位助记词
    ///
    /// - Parameter completion: 回调
    static func generateMnemonic(completion: @escaping GenerateMnemonicCallback) {
        let mnemonic = Crypto.generateMnemonic(strength: 128)
        let words = mnemonic.components(separatedBy: " ")
        var repeateWordsDetector = [String]()
        for word in words {
            if repeateWordsDetector.contains(word) {
                generateMnemonic(completion: completion)
                return
            }
            repeateWordsDetector.append(word)
        }
        completion(mnemonic)
    }

    /// 导入钱包
    ///
    /// - Parameters:
    ///   - importType: 导入类型
    ///   - completion: 导入结果回调
    static func importWallet(with importType: ImportType, completion: @escaping ImportResultCallback) {
        switch importType {
        case .keystore(let keystore, let password):
            importKeystoreAsync(keystore: keystore, password: password, completion: completion)
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
    static func importMnemonicAsync(mnemonic: String, password: String, devirationPath: String, completion: @escaping ImportResultCallback) {
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
        do {
            let wallet = try keyStore.import(mnemonic: mnemonic, encryptPassword: password, derivationPath: DerivationPath(devirationPath)!)
            return ImportResult.succeed(result: wallet.accounts[0])
        } catch {
            switch error {
            case KeyStore.Error.accountAlreadyExists:
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "钱包已经存在")
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
    ///   - keystore: json keystore密钥
    ///   - password: 密码
    ///   - completion: 回调
    static func importKeystoreAsync(keystore: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importKeystore(keystore: keystore, password: password)
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
    static func importKeystore(keystore: String, password: String) -> ImportResult<Account> {
        guard let data = keystore.data(using: .utf8) else {
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "无效的keystore")
        }

        do {
            let account = try keyStore.import(json: data, password: password, newPassword: password, coin: .ethereum).accounts[0]
            return ImportResult.succeed(result: account)
        } catch {
            switch error {
            case KeyStore.Error.accountAlreadyExists:
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "钱包已经存在")
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
        guard let data = Data(hexString: privateKey), let pk = PrivateKey(data: data) else {
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "导入私钥失败")
        }
        do {
            let wallet = try keyStore.import(privateKey: pk, password: password, coin: .ethereum)
            return ImportResult.succeed(result: wallet.accounts[0])
        } catch {
            switch error {
            case KeyStore.Error.accountAlreadyExists:
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "钱包已经存在")
            default:
                return ImportResult.failed(error: error, errorMessage: "钱包导入私钥失败失败")
            }
        }
    }

    public static func exportKeystore(wallet: Wallet, password: String) -> ExportResult<String> {
        do {
            let keystoreData = try keyStore.export(wallet: wallet, password: password, newPassword: password)
            guard let keystore = String(data: keystoreData, encoding: .utf8) else {
                return ExportResult.failed(error: ExportError.unknownError)
            }
            return ExportResult.succeed(result: keystore)
        } catch {
            return ExportResult.failed(error: ExportError.invalidPassword)
        }
    }

    /// exportPrivate async
    ///
    /// - Parameters:
    ///   - account: account
    ///   - password: password
    ///   - completion: ImportResult<String>
    static func exportPrivateKeyAsync(wallet: Wallet, password: String, completion:@escaping ExportPrivateCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let privateKey = exportPrivateKey(wallet: wallet, password: password)
            DispatchQueue.main.async {
                completion(privateKey)
            }
        }
    }

    static func exportPrivateKey(wallet: Wallet, password: String) -> ImportResult<String> {
        do {
            let account = wallet.accounts.first!
            let privateKey = try account.privateKey(password: password)
            return ImportResult.succeed(result: privateKey.data.toHexString())
        } catch {
            return ImportResult.failed(error: error, errorMessage: "导出私钥失败")
        }
    }

    static func checkWalletName(name: String) -> Bool {
        let appModel = WalletRealmTool.getCurrentAppModel()
        var nameArr = [""]
        for wallModel in appModel.wallets {
            nameArr.append(wallModel.name)
        }
        if  nameArr.contains(name) {
            return false
        } else {
            return true
        }
    }

    static func checkPassword(wallet: Wallet, password: String) -> Bool {
        do {
            var privateKeyData = try wallet.key.decrypt(password: password)
            defer {
                privateKeyData.resetBytes(in: 0 ..< privateKeyData.count)
            }
            return true
        } catch {
            return false
        }
    }
}
