//
//  DAppCommand.swift
//  Cyton
//
//  Created by XiaoLu on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

enum ChainType {
    case cita
    case eth
}

struct DAppCommonModel: Decodable {
    let name: Method
    let id: Int
    let chainType: ChainType
    private let object: Any

    var eth: ETHObject? {
        return object as? ETHObject
    }
    var cita: CITAObject? {
        return object as? CITAObject
    }

    enum CodingKeys: String, CodingKey {
        case name
        case id
        case chainType
        case object
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try! values.decode(Method.self, forKey: .name)
        id = try! values.decode(Int.self, forKey: .id)
        if try! values.decode(String.self, forKey: .chainType) == "CITA" {
            chainType = .cita
            object = try! values.decode(CITAObject.self, forKey: .object)
        } else {
            chainType = .eth
            object = try! values.decode(ETHObject.self, forKey: .object)
        }
    }
}

struct CITAObject: Decodable {
    let chainId: String
    let data: String?
    let nonce: String?
    var quota: String?
    let to: String
    let validUntilBlock: UInt64
    var value: String?
    let version: Int

    enum CodingKeys: String, CodingKey {
        case chainId
        case data
        case value
        case nonce
        case quota
        case to
        case validUntilBlock
        case version
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chainId = try! values.decode(String.self, forKey: .chainId)
        data = try? values.decode(String.self, forKey: .data)
        to = try! values.decode(String.self, forKey: .to)
        version = try! values.decode(Int.self, forKey: .version)
        validUntilBlock = try! values.decode(UInt64.self, forKey: .validUntilBlock)
        if let nonce = try? values.decode(String.self, forKey: .nonce) {
            self.nonce = nonce
        } else if let nonce = try? values.decode(UInt64.self, forKey: .nonce) {
            self.nonce = String(nonce)
        } else {
            self.nonce = nil
        }
        if let quota = try? values.decode(String.self, forKey: .quota) {
            self.quota = quota
        } else if let quota = try? values.decode(UInt64.self, forKey: .quota) {
            self.quota = String(quota)
        } else {
            self.quota = nil
        }
        if let value = try? values.decode(String.self, forKey: .value) {
            self.value = value
        } else if let value = try? values.decode(UInt64.self, forKey: .value) {
            self.value = String(value)
        } else {
            self.value = nil
        }
    }

    static func formatValue(value: String) -> BigUInt? {
        let finalValue: BigUInt?
        if value.hasPrefix("0x") {
            finalValue = BigUInt(value.removeHexPrefix(), radix: 16)
        } else {
            finalValue = BigUInt(value, radix: 10)
        }
        return finalValue
    }
}

struct ETHObject: Decodable {
    var chainId: Int?
    var value: String?
    var data: String?
    var from: String?
    var to: String?
    var gasLimit: String?
    var gasPrice: String?

    enum CodingKeys: String, CodingKey {
        case chainId
        case value
        case data
        case from
        case to
        case gasLimit
        case gasPrice
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chainId = try? values.decode(Int.self, forKey: .chainId)
        data = try? values.decode(String.self, forKey: .data)
        from = try? values.decode(String.self, forKey: .from)
        to = try? values.decode(String.self, forKey: .to)
        if let value = try? values.decode(String.self, forKey: .value) {
            self.value = value
        }
        if let gasPrice = try? values.decode(String.self, forKey: .gasPrice) {
            self.gasPrice = gasPrice
        }
        if let gasLimit = try? values.decode(String.self, forKey: .gasLimit) {
            self.gasLimit = gasLimit
        }
    }
}

enum DAppError: Error {
    case signTransactionFailed
    case sendTransactionFailed
    case signMessageFailed
    case signPersonalMessagFailed
    case userCanceled
}
