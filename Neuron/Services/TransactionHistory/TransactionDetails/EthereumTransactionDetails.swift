//
//  EthereumTransactionDetails.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

// http://api-rinkeby.etherscan.io/api?action=txlist&address=0xaBea5A6e72B02511Bd6cAf996A1b4C6aC477Ff71&apikey=T9GV1IF4V7YDXQ8F53U1FK2KHCE2KUUD8Z&module=account&offset=20&page=1&sort=desc
class EthereumTransactionDetails: TransactionDetails {
    var nonce: BigUInt = 0
    var blockHash: String = ""
    var transactionIndex: BigUInt = 0
    var gas: BigUInt = 0
    var gasPrice: BigUInt = 0
    var input: String = ""
    var contractAddress: String = ""
    var cumulativeGasUsed: BigUInt = 0
    var gasUsed: BigUInt = 0
    var confirmations: UInt = 0

    var isError = false
    var txreceipt_status: Int = 0

    enum EthereumCodingKeys: String, CodingKey {
        case timeStamp
        case nonce
        case blockHash
        case transactionIndex
        case gas
        case gasPrice
        case gasUsed
        case input
        case contractAddress
        case cumulativeGasUsed
        case confirmations

        case isError
        case txreceipt_status
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: EthereumCodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .timeStamp) {
            date = Date(timeIntervalSince1970: TimeInterval(value) ?? 0.0)
        }
        if let value = try? values.decode(String.self, forKey: .nonce) {
            nonce = BigUInt(value) ?? 0
        }
        blockHash = (try? values.decode(String.self, forKey: .blockHash)) ?? ""
        contractAddress = (try? values.decode(String.self, forKey: .contractAddress)) ?? ""
        if let value = try? values.decode(String.self, forKey: .transactionIndex) {
            transactionIndex = BigUInt(value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .gas) {
            gas = BigUInt(value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .gasPrice) {
            gasPrice = BigUInt(value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .gasUsed) {
            gasUsed = BigUInt(value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .cumulativeGasUsed) {
            cumulativeGasUsed = BigUInt(value) ?? 0
        }
        input = (try? values.decode(String.self, forKey: .input)) ?? ""
        if let value = try? values.decode(String.self, forKey: .confirmations) {
            confirmations = UInt(value) ?? 0
        }

        if let value = try? values.decode(String.self, forKey: .isError) {
            isError = Bool(value) ?? false
        }
        if let value = try? values.decode(String.self, forKey: .txreceipt_status) {
            txreceipt_status = Int(value) ?? 0
        }
    }
}
