//
//  WalletManager.swift
//  Neuron
//
//

import Foundation
import web3swift

struct Wallet {
    let address: String

    fileprivate var keystore: EthereumKeystoreV3 {
        return WalletManager.default.keystoreManager.walletForAddress(EthereumAddress(address)!)!
    }
}

struct WalletManager {
    typealias ImportResultCallback = (ImportResult<Wallet>) -> Void
    typealias ExportPrivateCallback = (ImportResult<String>) -> Void

    static let defaultDerivationPath = "m/44'/60'/0'/0/0"

    static let `default` = WalletManager(path: "keystore")

    let keystorePath: String
    var keystoreDir: URL {
        return  URL(fileURLWithPath: keystorePath)
    }
    let keystoreManager: WalletKeystoreManager

    /// Path will be always under user's document directory and excluded from iCloud backup
    init(path: String) {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        keystorePath =  documentDir + "/" + "keystore"
        keystoreManager = WalletKeystoreManager.managerForPath(keystorePath)!
    }

    static func generateMnemonic() -> String {
        return try! BIP39.generateMnemonics(bitsOfEntropy: 128)!
    }

    func wallet(for address: String) -> Wallet? {
        if doesWalletExist(address: address) {
            return Wallet(address: address)
        }
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

    func importMnemonic(mnemonic: String, password: String, derivationPath: String) -> ImportResult<Wallet> {
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

            let url = makeURL(for: address)
            try save(data: keystore.serialize()!, to: url)
            keystoreManager.register(url: url, for: address)

            return ImportResult.succeed(result: Wallet(address: address))
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

    func importKeystore(_ keystoreString: String, password: String) -> ImportResult<Wallet> {
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
            let url = makeURL(for: address)
            try save(data: keystore.serialize()!, to: url)
            keystoreManager.register(url: url, for: address)
        } catch {
            return ImportResult.failed(error: ImportError.unknown, errorMessage: "钱包导入失败")
        }

        return ImportResult.succeed(result: Wallet(address: address))
    }

    func importPrivateKeyAsync(privateKey: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let importResult = self.importPrivateKey(privateKey: privateKey, password: password)
            DispatchQueue.main.async {
                completion(importResult)
            }
        }
    }

    func importPrivateKey(privateKey: String, password: String) -> ImportResult<Wallet> {
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

            let url = makeURL(for: address)
            try save(data: keystore.serialize()!, to: url)
            keystoreManager.register(url: url, for: address)
            return ImportResult.succeed(result: Wallet(address: address))
        } catch {
            return ImportResult.failed(error: ImportError.unknown, errorMessage: "钱包导入失败")
        }
    }

    public func exportKeystore(wallet: Wallet, password: String) -> ExportResult<String> {
        guard verifyPassword(wallet: wallet, password: password) else {
            return ExportResult.failed(error: ExportError.invalidPassword)
        }

        do {
            if let data = try wallet.keystore.serialize() {
                return ExportResult.succeed(result: String(data: data, encoding: .utf8)!)
            }

            return ExportResult.failed(error: ExportError.accountNotFound)
        } catch let error {
            return ExportResult.failed(error: error)
        }
    }

    func exportPrivateKey(wallet: Wallet, password: String) -> ImportResult<String> {
        do {
            var privateKey = try wallet.keystore.UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress(wallet.address)!)
            defer { Data.zero(&privateKey) }
            return ImportResult.succeed(result: String(data: privateKey, encoding: .utf8)!)
        } catch let error {
            return ImportResult.failed(error: error, errorMessage: "导出私钥失败")
        }
    }
}

extension WalletManager {
    func updatePassword(wallet: Wallet, password: String, newPassword: String) throws {
        do {
            let keystore = wallet.keystore
            try keystore.regenerate(oldPassword: password, newPassword: password)
            guard let url = keystoreManager.url(for: wallet.address) else {
                throw KeystoreError.accountNotFound
            }

            try save(data: keystore.serialize()!, to: url)
        } catch {
            throw KeystoreError.failedToUpdatePassword
        }
    }

    func deleteWallet(wallet: Wallet, password: String) throws {
        guard verifyPassword(wallet: wallet, password: password) else {
            throw KeystoreError.invalidPassword
        }
        guard let url = keystoreManager.url(for: wallet.address) else {
            throw KeystoreError.failedToDeleteAccount
        }
        try delete(url: url)
        keystoreManager.unregister(address: wallet.address)
    }
}

// MARK: - Validations
extension WalletManager {
    func doesWalletExist(address: String) -> Bool {
        let allAddresses = keystoreManager.addresses.map { $0.address }
        return allAddresses.map { $0.removeHexPrefix().lowercased() }.contains(address.removeHexPrefix().lowercased())
    }

    func doesWalletExist(name: String) -> Bool {
        return WalletRealmTool.getCurrentAppModel().wallets.map { $0.name }.contains(name)
    }

    func verifyPassword(wallet: Wallet, password: String) -> Bool {
        switch exportKeystore(wallet: wallet, password: password) {
        case .succeed(result: _):
            return true
        default:
            return false
        }
    }
}

// MARK: - Keystore Disk Storage
private extension WalletManager {
    func makeURL(for address: String?) -> URL {
        let identifier: String
        if let address = address {
            identifier = address.removeHexPrefix().lowercased()
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

    func delete(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
