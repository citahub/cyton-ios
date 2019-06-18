//
//  WalletKeystoreManager.swift
//  Cyton
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

    private init?(_ path: String) throws {
        self.path = path
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        if !exists && !isDir.boolValue {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
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

    func privateKey(for address: EthereumAddress, password: String) throws -> Data {
        guard let keystore = keystore(for: address) else {
            throw AbstractKeystoreError.invalidAccountError
        }
        return try keystore.UNSAFE_getPrivateKeyData(password: password, account: address)
    }

    func keystore(for address: EthereumAddress) -> EthereumKeystoreV3? {
        return keystores.first { $0.getAddress() == address }
    }

    func add(keystore: EthereumKeystoreV3) throws {
        let address = keystore.getAddress()!.address
        let url = makeURL(for: address)
        try save(data: keystore.serialize()!, to: url)
        keystores.append(keystore)
        register(url: url, for: address)
    }

    func update(keystore: EthereumKeystoreV3) throws {
        try save(data: keystore.serialize()!, to: url(for: keystore.addresses!.first!.address)!)
        keystores.removeAll(where: { $0.getAddress()! == keystore.getAddress()! })
        keystores.append(keystore)
    }

    func remove(keystore: EthereumKeystoreV3) throws {
        let address = keystore.addresses!.first!.address
        try delete(url: url(for: address)!)
        keystores.removeAll(where: { $0.getAddress()! == keystore.getAddress()! })
        unregister(address: address)
    }
}

private extension WalletKeystoreManager {
    func save(data: Data, to url: URL) throws {
        try data.write(to: url, options: [.atomicWrite])
    }

    func delete(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    func register(url: URL, for address: String) {
        addressToURLs[address.lowercased()] = url
    }

    func unregister(address: String) {
        addressToURLs[address.lowercased()] = nil
    }
}

// MARK: - Keystore name(URL)

private extension WalletKeystoreManager {
    func url(for address: String) -> URL? {
        return addressToURLs[address.lowercased()]
    }

    func makeURL(for address: String?) -> URL {
        let identifier: String
        if let address = address {
            identifier = address.removeHexPrefix().lowercased()
        } else {
            identifier = UUID().uuidString
        }

        return URL(fileURLWithPath: path + "/" + generateFileName(identifier: identifier))
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
}
