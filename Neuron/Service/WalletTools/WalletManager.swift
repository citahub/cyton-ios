//
//  WalletManager.swift
//  Neuron
//
//

import Foundation
import web3swift

struct Account {
    let address: String
}

struct WalletManager {
    typealias ImportResultCallback = (ImportResult<Account>) -> Void
    typealias ExportPrivateCallback = (ImportResult<String>) -> Void

    static let defaultDerivationPath = "m/44'/60'/0'/0/0"

    static let `default` = WalletManager(path: "keystore")

    let keystorePath: String
    var keystoreDir: URL {
        return  URL(fileURLWithPath: keystorePath)
    }
    let keystoreManager: KeystoreManager

    /// Path will be always under user's document directory and excluded from iCloud backup
    init(path: String) {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        keystorePath =  documentDir + "/" + "keystore"
        keystoreManager = KeystoreManager.managerForPath(keystorePath)!
    }

    var addresses: [String] {
        return keystoreManager.addresses!.map { $0.address }
    }

    static func generateMnemonic() -> String {
        return try! BIP39.generateMnemonics(bitsOfEntropy: 128)!
    }

    func account(for address: String) -> Account? {
        // TODO
        return nil
    }

    func importWallet(with importType: ImportType, completion: @escaping ImportResultCallback) {
        switch importType {
        case .keystore(let keystore, let password):
            importKeystoreAsync(keystore: keystore, password: password, completion: completion)
        case .privateKey(let privateKey, let password):
            importPrivateKeyAsync(privateKey: privateKey, password: password, completion: completion)
        case .mnemonic(let mnemonic, let password, let derivationPath):
            importMnemonicAsync(mnemonic: mnemonic, password: password, derivationPath: derivationPath, completion: completion)
        }
    }

    func importMnemonicAsync(mnemonic: String, password: String, derivationPath: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = self.importMnemonic(mnemonic: mnemonic, password: password, derivationPath: derivationPath)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    func importMnemonic(mnemonic: String, password: String, derivationPath: String) -> ImportResult<Account> {
        do {
            guard let keystore = try BIP32Keystore(mnemonics: mnemonic, password: password, prefixPath: derivationPath) else {
                return ImportResult.failed(error: ImportError.invalidateMnemonic, errorMessage: "钱包导入失败")
            }

            guard let address = keystore.addresses?.first?.address else {
                return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "私钥不正确")
            }
            if doesWalletExist(address: address) {
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "钱包已存在")
            }

            try save(data: keystore.serialize()!, to: makeURL(for: address))

            return ImportResult.succeed(result: Account(address: address))
        } catch let error {
            return ImportResult.failed(error: error, errorMessage: "钱包导入失败")
        }
    }

    func importKeystoreAsync(keystore: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = self.importKeystore(keystore, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    func importKeystore(_ keystoreString: String, password: String) -> ImportResult<Account> {
        guard let keystore = EthereumKeystoreV3(keystoreString) else {
            return ImportResult.failed(error: ImportError.invalidateJSONKey, errorMessage: "无效的keystore")
        }

        guard let address = keystore.getAddress()?.address else {
            return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "私钥不正确")
        }
        if doesWalletExist(address: address) {
            return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "钱包已存在")
        }

        do {
            try keystore.regenerate(oldPassword: password, newPassword: password)
        } catch {
            return ImportResult.failed(error: ImportError.wrongPassword, errorMessage: "密码错误")
        }

        do {
            try save(data: keystore.serialize()!, to: makeURL(for: address))
        } catch {
            return ImportResult.failed(error: ImportError.unknown, errorMessage: "钱包导入失败")
        }

        return ImportResult.succeed(result: Account(address: address))
    }

    func importPrivateKeyAsync(privateKey: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = self.importPrivateKey(privateKey: privateKey, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    func importPrivateKey(privateKey: String, password: String) -> ImportResult<Account> {
        do {
            guard let data = Data.fromHex(privateKey.trimmingCharacters(in: .whitespacesAndNewlines)),
                let keystore = try EthereumKeystoreV3(privateKey: data, password: password) else {
                return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "私钥不正确")
            }

            guard let address = keystore.getAddress()?.address else {
                return ImportResult.failed(error: ImportError.invalidatePrivateKey, errorMessage: "私钥不正确")
            }
            if doesWalletExist(address: address) {
                return ImportResult.failed(error: ImportError.accountAlreadyExists, errorMessage: "钱包已存在")
            }

            try save(data: keystore.serialize()!, to: makeURL(for: address))
            return ImportResult.succeed(result: Account(address: address))
        } catch {
            return ImportResult.failed(error: ImportError.unknown, errorMessage: "钱包导入失败")
        }
    }

    public func exportKeystore(account: Account, password: String) -> ExportResult<String> {
        do {
            // TODO
            let keystore = ""
            return ExportResult.succeed(result: keystore)
        } catch {
            return ExportResult.failed(error: ExportError.invalidPassword)
        }
    }

    func exportPrivateKey(account: Account, password: String) -> ImportResult<String> {
        do {
            // TODO
            let privateKey = ""
            return ImportResult.succeed(result: privateKey)
        } catch {
            return ImportResult.failed(error: error, errorMessage: "导出私钥失败")
        }
    }
}

extension WalletManager {
    func updatePassword(address: String, password: String, newPassword: String) throws {
        let account = self.account(for: address)!
        // TODO
        throw KeystoreError.accountNotFound
    }

    func deleteWallet(address: String, password: String) throws {
        let account = self.account(for: address)!
        // TODO
        throw KeystoreError.accountNotFound
    }

    func getKeystoreForCurrentWallet(password: String) throws -> String {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        let account = self.account(for: walletModel.address)!
        // TODO
        throw KeystoreError.accountNotFound
    }
}

// MARK: - Validations
extension WalletManager {
    func doesWalletExist(address: String) -> Bool {
        return addresses.map { $0.removeHexPrefix().lowercased() }.contains(address.removeHexPrefix().lowercased())
    }

    func doesWalletExist(name: String) -> Bool {
        return WalletRealmTool.getCurrentAppModel().wallets.map { $0.name }.contains(name)
    }

    func verifyPassword(account: Account, password: String) -> Bool {
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
private extension WalletManager {
    func makeURL(for address: String?) -> URL {
        let identifier: String
        if let address = address {
            identifier = address.removeHexPrefix()
        } else {
            identifier = UUID().uuidString
        }

        return keystoreDir.appendingPathComponent(generateFileName(identifier: identifier))
    }

    func generateFileName(identifier: String, date: Date = Date(), timeZone: TimeZone = .current) -> String {
        return "UTC--\(filenameTimestamp(for: date, in: timeZone))--\(identifier)"
    }

    func filenameTimestamp(for date: Date, in timeZone: TimeZone = .current) -> String {
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

    func save(data: Data, to url: URL) throws {
        try data.write(to: url, options: [.atomicWrite])
    }
}
