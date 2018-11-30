//
//  DAppCommand.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

struct DAppCommonModel: Decodable {
    let name: Method
    let id: Int
    let chainType: String
    private let object: Any

    var eth: ETHObject? {
        return object as? ETHObject
    }
    var appChain: AppChainObject? {
        return object as? AppChainObject
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
        chainType = try! values.decode(String.self, forKey: .chainType)

        if chainType == "AppChain" {
            object = try! values.decode(AppChainObject.self, forKey: .object)
        } else {
            object = try! values.decode(ETHObject.self, forKey: .object)
        }
    }
}

struct AppChainObject: Decodable {
    let chainId: Int
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
        chainId = try! values.decode(Int.self, forKey: .chainId)
        data = try? values.decode(String.self, forKey: .data)
        to = try! values.decode(String.self, forKey: .to)
        version = try! values.decode(Int.self, forKey: .version)
        validUntilBlock = try! values.decode(UInt64.self, forKey: .validUntilBlock)
        nonce = try? values.decode(String.self, forKey: .nonce)
        if let quota = try? values.decode(String.self, forKey: .quota) {
            self.quota = quota
        }
        if let value = try? values.decode(String.self, forKey: .value) {
            self.value = value
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
