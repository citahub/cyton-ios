//
//  TokenModel.swift
//  Cyton
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt

class TokenModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var iconUrl: String? = ""
    @objc dynamic var address = ""
    @objc dynamic var decimals = 18
    @objc dynamic var symbol = ""
    @objc dynamic var identifier = UUID().uuidString

    // defaults false, eth and RPC "getMateData" is true.
    @objc dynamic var isNativeToken = false
    @objc dynamic var chainIdentifier: String = ""

    var chain: ChainModel {
        switch type {
        case .ether, .erc20:
            return EthereumNetwork().chain
        case .cita, .citaErc20:
            return (try! Realm()).object(ofType: ChainModel.self, forPrimaryKey: chainIdentifier)!
        }
    }

    override class func primaryKey() -> String? { return "identifier" }

    override static func ignoredProperties() -> [String] { return ["currencyAmount"] }
}

extension TokenModel {
    var type: TokenType {
        if isNativeToken {
            if chainIdentifier == "" && address == "" {
                return .ether
            } else {
                return .cita
            }
        } else if chainIdentifier != "" && address != "" {
            return .citaErc20
        } else {
            return .erc20
        }
    }

    var isEthereum: Bool {
        return type == .ether || type == .erc20
    }
}

extension TokenModel {
    static func identifier(for tokenModel: TokenModel) -> String? {
        return (try! Realm()).objects(TokenModel.self).first(where: { $0 == tokenModel })?.identifier
    }
}

extension TokenModel {
    public static func == (lhs: TokenModel, rhs: TokenModel) -> Bool {
        return lhs.symbol == rhs.symbol && lhs.name == rhs.name
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TokenModel else { return false }
        return object.address == address
    }
}
