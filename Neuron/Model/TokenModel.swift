//
//  TokenModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt

class TokenModel: Object, Decodable {
    @objc dynamic var tokenBalance = ""
    @objc dynamic var currencyAmount = ""
    @objc dynamic var name = ""
    @objc dynamic var iconUrl: String? = ""
    @objc dynamic var address = ""
    @objc dynamic var decimals = 0
    @objc dynamic var symbol = ""
    @objc dynamic var chainName: String? = ""
    @objc dynamic var chainidName = "" // chainId + name
    @objc dynamic var chainId = ""
    @objc dynamic var chainHosts = "" // manifest.json chainSet.values.first

    // defaults false, eth and RPC "getMateData" is true.
    @objc dynamic var isNativeToken = false

    override class func primaryKey() -> String? {
        return "chainidName"
    }

    override static func ignoredProperties() -> [String] {
        return ["tokenBalance", "currencyAmount"]
    }

    struct Logo: Decodable {
        var src: String?
    }
    var logo: Logo?

    enum `Type`: String, Decodable {
        case erc20
        case ethereum
        case nervos
        case nervosErc20
    }
    var type: Type {
        if isNativeToken {
            if chainId == NativeChainId.ethMainnetChainId {
                return .ethereum
            } else {
                if address != "" {
                    return .nervosErc20
                } else {
                    return .nervos
                }
            }
        } else {
            return .erc20
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case address
        case decimals
        case symbol
        case logo
    }
}

extension TokenModel {
    public static func == (lhs: TokenModel, rhs: TokenModel) -> Bool {
        return lhs.address == rhs.address
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TokenModel else { return false }
        return object.address == address
    }
}
