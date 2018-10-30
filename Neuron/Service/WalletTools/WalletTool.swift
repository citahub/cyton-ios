//
//  WalletTool.swift
//  Neuron
//
//

import Foundation
import web3swift
import Result

struct Account {
    let address: String
}

struct WalletTool {
    static let defaultDerivationPath = "m/44'/60'/0'/0/0"
    typealias ImportResultCallback = (ImportResult<Account>) -> Void
    typealias ExportPrivateCallback = (ImportResult<String>) -> Void

    static var keystorePath: String = {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentDir + "/keystore"
    }()
    static let keystoreDir = URL(fileURLWithPath: keystorePath)
    static let keystoreManager = KeystoreManager.managerForPath(keystorePath)!

    static func account(for address: String) -> Account? {
        // TODO
        return nil
    }

    static func generateMnemonic() -> String {
        return try! BIP39.generateMnemonics(bitsOfEntropy: 128)!
    }

    static func importWallet(with importType: ImportType, completion: @escaping ImportResultCallback) {
        switch importType {
        case .keystore(let keystore, let password):
            importKeystoreAsync(keystore: keystore, password: password, completion: completion)
        case .privateKey(let privateKey, let password):
            importPrivateKeyAsync(privateKey: privateKey, password: password, completion: completion)
        case .mnemonic(let mnemonic, let password, let derivationPath):
            importMnemonicAsync(mnemonic: mnemonic, password: password, derivationPath: derivationPath, completion: completion)
        }
    }

    static func importMnemonicAsync(mnemonic: String, password: String, derivationPath: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importMnemonic(mnemonic: mnemonic, password: password, derivationPath: derivationPath)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    static func importMnemonic(mnemonic: String, password: String, derivationPath: String) -> ImportResult<Account> {
        do {
            guard let keystore = try BIP32Keystore(mnemonics: mnemonic, password: password, prefixPath: derivationPath) else {
                return ImportResult.failed(error: ImportError.invalidateMnemonic, errorMessage: "钱包导入失败")
            }

            // TODO: check ImportError.accountAlreadyExists
            // TODO: Save
            return ImportResult.succeed(result: Account(address: keystore.addresses!.first!.address))
        } catch let error {
            return ImportResult.failed(error: error, errorMessage: "钱包导入失败")
        }
    }

    static func importKeystoreAsync(keystore: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importKeystore(keystore, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    static func importKeystore(_ keystoreString: String, password: String) -> ImportResult<Account> {
        guard let keystore = EthereumKeystoreV3(keystoreString) else {
            return ImportResult.failed(error: ImportError.invalidateJSONKey, errorMessage: "无效的keystore")
        }

        do {
            try keystore.regenerate(oldPassword: password, newPassword: password)
            // TODO: check ImportError.accountAlreadyExists
            // TODO: Save
            return ImportResult.succeed(result: Account(address: keystore.addresses!.first!.address))
        } catch {
            return ImportResult.failed(error: ImportError.wrongPassword, errorMessage: "密码错误")
        }
    }

    static func importPrivateKeyAsync(privateKey: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = importPrivateKey(privateKey: privateKey, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    static func importPrivateKey(privateKey: String, password: String) -> ImportResult<Account> {
        do {
            guard let data = Data.fromHex(privateKey.trimmingCharacters(in: .whitespacesAndNewlines)),
                let keystore = try EthereumKeystoreV3(privateKey: data, password: password) else {
                return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "私钥不正确")
            }

            // TODO: check ImportError.accountAlreadyExists
            return ImportResult.succeed(result: Account(address: keystore.addresses!.first!.address))
        } catch {
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "私钥不正确")
        }
    }

    public static func exportKeystore(account: Account, password: String) -> ExportResult<String> {
        do {
            // TODO
            let keystore = ""
            return ExportResult.succeed(result: keystore)
        } catch {
            return ExportResult.failed(error: ExportError.invalidPassword)
        }
    }

    static func exportPrivateKey(account: Account, password: String) -> ImportResult<String> {
        do {
            // TODO
            let privateKey = ""
            return ImportResult.succeed(result: privateKey)
        } catch {
            return ImportResult.failed(error: error, errorMessage: "导出私钥失败")
        }
    }
}

extension WalletTool {
    static func updatePassword(address: String, password: String, newPassword: String) throws {
        let account = WalletTool.account(for: address)!
        // TODO
        throw KeystoreError.accountNotFound
    }

    static func deleteWallet(address: String, password: String) throws {
        let account = WalletTool.account(for: address)!
        // TODO
        throw KeystoreError.accountNotFound
    }

    static func getKeystoreForCurrentWallet(password: String) throws -> String {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        let account = WalletTool.account(for: walletModel.address)!
        // TODO
        throw KeystoreError.accountNotFound
    }
}

extension WalletTool {
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

    static func checkPassword(account: Account, password: String) -> Bool {
        do {
            // TODO
            var privateKeyData = "todo"
            defer {
                // TODO reset privateKeyData
            }
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Keystore Disk Storage
private extension WalletTool {
    static func makeURL(for address: String?) -> URL {
        let identifier: String
        if let address = address {
            identifier = address.removeHexPrefix()
        } else {
            identifier = UUID().uuidString
        }

        return keystoreDir.appendingPathComponent(generateFileName(identifier: identifier))
    }

    static func generateFileName(identifier: String, date: Date = Date(), timeZone: TimeZone = .current) -> String {
        return "UTC--\(filenameTimestamp(for: date, in: timeZone))--\(identifier)"
    }

    static func filenameTimestamp(for date: Date, in timeZone: TimeZone = .current) -> String {
        let tz: String
        let offset = timeZone.secondsFromGMT()
        if offset == 0 {
            tz = "Z"
        } else {
            tz = String(format: "%03d00", offset / 60)
        }

        let components = Calendar(identifier: .iso8601).dateComponents(in: timeZone, from: date)
        return "\(components.year!)-\(components.month!)-\(components.day!)T\(components.hour!)-\(components.minute!)-\(components.second!).\(components.nanosecond!)\(tz)"
    }

    static func save(data: Data, to url: URL) throws {
        //let json = try JSONEncoder().encode(key)
        try data.write(to: url, options: [.atomicWrite])
    }
}
