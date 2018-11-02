//
//  WalletManager.swift
//  Neuron
//
//

import Foundation
import web3swift

// Plain object for passing around
struct Wallet {
    let address: String
}

struct WalletManager {
    typealias ImportResultCallback = (ImportResult<Wallet>) -> Void
    typealias ExportPrivateCallback = (ImportResult<String>) -> Void

    static let `default` = WalletManager(path: "keystore")

    private let keystorePath: String
    var keystoreDir: URL {
        return URL(fileURLWithPath: keystorePath)
    }
    private let keystoreManager: WalletKeystoreManager

    /// If fullPath is false, path will be always under user's document directory and excluded from iCloud backup.
    init(path: String, fullPath: Bool = false) {
        if fullPath {
            keystorePath = path
        } else {
            let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            keystorePath =  documentDir + "/" + path
        }
        keystoreManager = WalletKeystoreManager.managerForPath(keystorePath)!
    }

    func wallet(for address: String) -> Wallet? {
        if walletExists(address: address) {
            return Wallet(address: address)
        }
        return nil
    }

    func keystore(for address: String) -> EthereumKeystoreV3 {
        return keystoreManager.keystore(for: EthereumAddress(address)!)!
    }
}

// MARK: - Import
extension WalletManager {
    func importWallet(with importType: ImportType, completion: @escaping ImportResultCallback) {
        switch importType {
        case .keystore(let keystore, let password):
            importKeystoreAsync(keystore: keystore, password: password, completion: completion)
        case .privateKey(let privateKey, let password):
            importPrivateKeyAsync(privateKey: privateKey, password: password, completion: completion)
        case .mnemonic(let mnemonic, let password):
            importMnemonicAsync(mnemonic: mnemonic, password: password, completion: completion)
        }
    }

    func importMnemonicAsync(mnemonic: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: ImportResult<Wallet>
            do {
                let wallet = try self.importMnemonic(mnemonic: mnemonic, password: password)
                result = ImportResult.succeed(result: wallet)
            } catch let error {
                result = ImportResult.failed(error: error, errorMessage: "导入助记词失败")
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func importMnemonic(mnemonic: String, password: String) throws -> Wallet {
        guard let bip32Keystore = try BIP32Keystore(mnemonics: mnemonic, password: password, prefixPath: "m/44'/60'/0'/0"),
            let address = bip32Keystore.addresses?.first else {
            throw ImportError.invalidateMnemonic
        }

        if walletExists(address: address.address) {
            throw ImportError.accountAlreadyExists
        }

        var privateKey = try bip32Keystore.UNSAFE_getPrivateKeyData(password: password, account: address)
        defer { Data.zero(&privateKey) }
        guard let keystore = try EthereumKeystoreV3(privateKey: privateKey, password: password) else {
            throw ImportError.invalidateMnemonic
        }

        do {
            try keystoreManager.add(keystore: keystore)
        } catch {
            throw ImportError.unknown
        }

        return Wallet(address: address.address)
    }

    func importKeystoreAsync(keystore: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: ImportResult<Wallet>
            do {
                let wallet = try self.importKeystore(keystore, password: password)
                result = ImportResult.succeed(result: wallet)
            } catch let error {
                result = ImportResult.failed(error: error, errorMessage: "导入Keystore失败")
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func importKeystore(_ keystoreString: String, password: String) throws -> Wallet {
        guard let keystore = EthereumKeystoreV3(keystoreString), let address = keystore.getAddress()?.address else {
            throw ImportError.invalidateJSONKey
        }

        if walletExists(address: address) {
            throw ImportError.accountAlreadyExists
        }

        do {
            try keystore.regenerate(oldPassword: password, newPassword: password)
        } catch {
            throw ImportError.wrongPassword
        }

        do {
            try keystoreManager.add(keystore: keystore)
        } catch {
            throw ImportError.unknown
        }

        return Wallet(address: address)
    }

    func importPrivateKeyAsync(privateKey: String, password: String, completion: @escaping ImportResultCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: ImportResult<Wallet>
            do {
                let wallet = try self.importPrivateKey(privateKey: privateKey, password: password)
                result = ImportResult.succeed(result: wallet)
            } catch let error {
                result = ImportResult.failed(error: error, errorMessage: "导入私钥失败")
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func importPrivateKey(privateKey: String, password: String) throws -> Wallet {
        guard let data = Data.fromHex(privateKey.trimmingCharacters(in: .whitespacesAndNewlines)),
            let keystore = try EthereumKeystoreV3(privateKey: data, password: password),
            let address = keystore.getAddress()?.address else {
            throw ImportError.invalidatePrivateKey
        }

        if walletExists(address: address) {
            throw ImportError.accountAlreadyExists
        }

        do {
            try keystoreManager.add(keystore: keystore)
        } catch {
            throw ImportError.unknown
        }

        return Wallet(address: address)
    }
}

// MARK: - Export
extension WalletManager {
    public func exportKeystore(wallet: Wallet, password: String) throws -> String {
        guard verifyPassword(wallet: wallet, password: password) else {
            throw ExportError.invalidPassword
        }

        if let data = try keystore(for: wallet.address).serialize() {
            return String(data: data, encoding: .utf8)!
        }

        throw ExportError.accountNotFound
    }

    func exportPrivateKey(wallet: Wallet, password: String) throws -> String {
        do {
            var privateKey = try keystoreManager.privateKey(for: EthereumAddress(wallet.address)!, password: password)
            defer { Data.zero(&privateKey) }
            return privateKey.toHexString()
        } catch {
            throw ExportError.invalidPassword
        }
    }
}

// MARK: - Manage existing wallets
extension WalletManager {
    func updatePassword(wallet: Wallet, password: String, newPassword: String) throws {
        do {
            let keystore = self.keystore(for: wallet.address)
            try keystore.regenerate(oldPassword: password, newPassword: newPassword)
            try keystoreManager.update(keystore: keystore)
        } catch {
            throw KeystoreError.failedToUpdatePassword
        }
    }

    func deleteWallet(wallet: Wallet, password: String) throws {
        guard verifyPassword(wallet: wallet, password: password) else {
            throw KeystoreError.invalidPassword
        }
        try keystoreManager.remove(keystore: keystore(for: wallet.address))
    }
}

// MARK: - Validations & Checks
extension WalletManager {
    func walletExists(address: String) -> Bool {
        let allAddresses = keystoreManager.addresses.map { $0.address }
        return allAddresses.map { $0.removeHexPrefix().lowercased() }.contains(address.removeHexPrefix().lowercased())
    }

    func walletExists(name: String) -> Bool {
        return WalletRealmTool.getCurrentAppModel().wallets.map { $0.name }.contains(name)
    }

    func verifyPassword(wallet: Wallet, password: String) -> Bool {
        do {
            _ = try exportPrivateKey(wallet: wallet, password: password)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Generate mnemonic
extension WalletManager {
    static func generateMnemonic() -> String {
        return try! BIP39.generateMnemonics(bitsOfEntropy: 128)!
    }
}
