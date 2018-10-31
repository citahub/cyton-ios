//
//  WalletKeystoreManager.swift
//  Neuron
//
//  Created by James Chen on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import web3swift

/// Keystore storage management
/// All keystores are stored as V3 keystore despite its original type (plain private key, mnemonic (HD) or keystore).
class WalletKeystoreManager {
    private var path: String
    private var keystores = [EthereumKeystoreV3]()
    private var addressToURLs = [String: URL]()
    var addresses: [EthereumAddress] {
        return keystores.compactMap { $0.getAddress() }
    }

    static func managerForPath(_ path: String) -> WalletKeystoreManager? {
        do {
            return try WalletKeystoreManager(path)
        } catch {
            return nil
        }
    }

    public init(_ keystores: [EthereumKeystoreV3]) {
        self.keystores = keystores
        path = ""
    }

    private init?(_ path: String) throws {
        self.path = path
        var isDir: ObjCBool = false
        var exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        if !exists && !isDir.boolValue {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        }
        if !isDir.boolValue {
            return nil
        }
        for file in try FileManager.default.contentsOfDirectory(atPath: path) {
            let filePath = path + "/" + file
            guard let content = FileManager.default.contents(atPath: filePath) else {
                continue
            }
            guard let keystore = EthereumKeystoreV3(content) else {
                continue
            }
            keystores.append(keystore)
            register(url: URL(fileURLWithPath: filePath), for: keystore.getAddress()!.address)
        }
    }

    func getPrivateKey(account: EthereumAddress, password: String) throws -> Data {
        guard let keystore = self.walletForAddress(account) else {
            throw AbstractKeystoreError.invalidAccountError
        }
        return try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
    }

    func walletForAddress(_ address: EthereumAddress) -> EthereumKeystoreV3? {
        return keystores.first { $0.getAddress() == address }
    }

    func url(for address: String) -> URL? {
        return addressToURLs[address.lowercased()]
    }

    func register(url: URL, for address: String) {
        addressToURLs[address.lowercased()] = url
    }

    func unregister(address: String) {
        addressToURLs[address.lowercased()] = nil
    }
}
