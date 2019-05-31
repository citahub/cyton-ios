//
//  WalletManager.swift
//  Cyton
//
//

import Foundation
import web3swift

// Plain object for passing around
struct Wallet {
    let address: String
}

struct WalletManager {
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
    func importMnemonic(mnemonic: String, password: String) throws -> Wallet {
        guard let bip32Keystore = try BIP32Keystore(mnemonics: mnemonic, password: password, prefixPath: "m/44'/60'/0'/0"),
            let address = bip32Keystore.addresses?.first else {
            throw Error.invalidMnemonic
        }

        if walletExists(address: address.address) {
            throw Error.accountAlreadyExists
        }

        var privateKey = try bip32Keystore.UNSAFE_getPrivateKeyData(password: password, account: address)
        defer { Data.zero(&privateKey) }
        guard let keystore = try EthereumKeystoreV3(privateKey: privateKey, password: password, aesMode: "aes-128-ctr") else {
            throw Error.invalidMnemonic
        }

        return try add(keystore, address.address)
    }

    func importKeystore(_ keystoreString: String, password: String) throws -> Wallet {
        guard let keystore = EthereumKeystoreV3(keystoreString), let address = keystore.getAddress()?.address else {
            throw Error.invalidKeystore
        }

        if walletExists(address: address) {
            throw Error.accountAlreadyExists
        }

        do {
            try keystore.regenerate(oldPassword: password, newPassword: password)
        } catch let error {
            guard let error = error as? AbstractKeystoreError else { throw Error.unknown }
            switch error {
            case .invalidPasswordError:
                throw Error.invalidPassword
            default:
                throw Error.invalidKeystore
            }
        }
        return try add(keystore, address)
    }

    func importPrivateKey(privateKey: String, password: String) throws -> Wallet {
        guard let data = Data.fromHex(privateKey.trimmingCharacters(in: .whitespacesAndNewlines)),
            let keystore = try EthereumKeystoreV3(privateKey: data, password: password, aesMode: "aes-128-ctr"),
            let address = keystore.getAddress()?.address else {
            throw Error.invalidPrivateKey
        }

        if walletExists(address: address) {
            throw Error.accountAlreadyExists
        }

        return try add(keystore, address)
    }

    private func add(_ keystore: EthereumKeystoreV3, _ address: String) throws -> Wallet {
        do {
            try keystoreManager.add(keystore: keystore)
        } catch {
            throw Error.failedToSaveKeystore
        }

        return Wallet(address: address)
    }
}

// MARK: - Export

extension WalletManager {
    public func exportKeystore(wallet: Wallet, password: String) throws -> String {
        guard verifyPassword(wallet: wallet, password: password) else {
            throw Error.invalidPassword
        }

        if let data = try keystore(for: wallet.address).serialize() {
            return String(data: data, encoding: .utf8)!
        }

        throw Error.accountNotFound
    }

    func exportPrivateKey(wallet: Wallet, password: String) throws -> String {
        do {
            var privateKey = try keystoreManager.privateKey(for: EthereumAddress(wallet.address)!, password: password)
            defer { Data.zero(&privateKey) }
            return privateKey.toHexString()
        } catch {
            throw Error.invalidPassword
        }
    }
}

// MARK: - Manage existing wallets

extension WalletManager {
    func updatePassword(wallet: Wallet, password: String, newPassword: String) throws {
        let keystore = self.keystore(for: wallet.address)
        do {
            try keystore.regenerate(oldPassword: password, newPassword: newPassword)
        } catch {
            throw Error.invalidPassword
        }
        do {
            try keystoreManager.update(keystore: keystore)
        } catch {
            throw Error.failedToUpdatePassword
        }
    }

    func deleteWallet(wallet: Wallet, password: String) throws {
        guard verifyPassword(wallet: wallet, password: password) else {
            throw Error.invalidPassword
        }
        do {
            try keystoreManager.remove(keystore: keystore(for: wallet.address))
        } catch {
            throw Error.failedToDeleteAccount
        }
    }
}

// MARK: - Validations & Checks

extension WalletManager {
    func walletExists(address: String) -> Bool {
        let allAddresses = keystoreManager.addresses.map { $0.address }
        return allAddresses.map { $0.removeHexPrefix().lowercased() }.contains(address.removeHexPrefix().lowercased())
    }

    func walletExists(name: String) -> Bool {
        return AppModel.current.wallets.map { $0.name }.contains(name)
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
