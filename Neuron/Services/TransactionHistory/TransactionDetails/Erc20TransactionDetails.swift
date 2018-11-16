//
//  Erc20TransactionDetails.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

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
