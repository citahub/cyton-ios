//
//  Erc20TransactionDetails.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

// https://api.etherscan.io/api?module=account&action=tokentx&contractaddress=0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2&address=0x4e83362442b8d1bec281594cea3050c8eb01311c&page=1&offset=100&sort=asc&apikey=YourApiKeyToken
// http://api-rinkeby.etherscan.io/api?action=tokentx&address=0x800a0668f848900E3F850e3F6Fce41286023D211&apikey=T9GV1IF4V7YDXQ8F53U1FK2KHCE2KUUD8Z&contractaddress=0x06a6299bdbf0596b8fda14012b81eeb0eeb5c3cb&module=account&offset=10&page=1&sort=desc
class Erc20TransactionDetails: TransactionDetails {
    var nonce: BigUInt = 0
    var blockHash: String = ""
    var contractAddress: String = ""
    var tokenName: String = ""
    var tokenSymbol: String = ""
    var tokenDecimal: String = ""
    var transactionIndex: BigUInt = 0
    var gas: BigUInt = 0
    var gasPrice: BigUInt = 0
    var gasUsed: BigUInt = 0
    var cumulativeGasUsed: BigUInt = 0
    var input: String = ""
    var confirmations: UInt = 0

    enum Erc20CodingKeys: String, CodingKey {
        case timeStamp
        case nonce
        case blockHash
        case contractAddress
        case transactionIndex
        case gas
        case gasPrice
        case gasUsed
        case cumulativeGasUsed
        case input
        case confirmations

        case tokenName
        case tokenSymbol
        case tokenDecimal
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: Erc20CodingKeys.self)

        if let value = try? values.decode(String.self, forKey: .timeStamp) {
            date = Date(timeIntervalSince1970: TimeInterval(value) ?? 0.0)
        }
        if let value = try? values.decode(String.self, forKey: .nonce) {
            nonce = BigUInt(string: value) ?? 0
        }
        blockHash = (try? values.decode(String.self, forKey: .blockHash)) ?? ""
        contractAddress = (try? values.decode(String.self, forKey: .contractAddress)) ?? ""
        if let value = try? values.decode(String.self, forKey: .transactionIndex) {
            transactionIndex = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .gas) {
            gas = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .gasPrice) {
            gasPrice = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .gasUsed) {
            gasUsed = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .cumulativeGasUsed) {
            cumulativeGasUsed = BigUInt(string: value) ?? 0
        }
        input = (try? values.decode(String.self, forKey: .input)) ?? ""
        if let value = try? values.decode(String.self, forKey: .confirmations) {
            confirmations = UInt(value) ?? 0
        }

        tokenName = (try? values.decode(String.self, forKey: .tokenName)) ?? ""
        tokenSymbol = (try? values.decode(String.self, forKey: .tokenSymbol)) ?? ""
        tokenDecimal = (try? values.decode(String.self, forKey: .tokenDecimal)) ?? ""
    }
}
