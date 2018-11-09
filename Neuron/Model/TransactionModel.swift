//
//  TransactionModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

enum TransactionType: String {
    case ETH
    case ERC20
    case AppChain
    case AppChainERC20
}

class TransactionModel: NSObject, Decodable {
    var value = ""
    var from = ""
    var to = ""
    var hashString = ""
    var time: Date?
    var chainName = ""
    var gasUsed = ""
    var gas = ""
    var gasPrice = ""
    var blockNumber = ""
    var symbol = ""
    var transactionType = TransactionType.ETH.rawValue //default "ETH" include ERC20 transaction,  another one is "Nervos"
    var totleGas = ""

    var chainId = ""
    var formatTime = ""

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case hashString = "hash"
        case timeStamp
        case timestamp
        case gasPrice
        case gas
        case gasUsed
        case blockNumber
        case value
        case chainName
        case chainId
        case tokenSymbol
        case tokenName
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        from = try values.decode(String.self, forKey: .from)
        to = try values.decode(String.self, forKey: .to)
        hashString = try values.decode(String.self, forKey: .hashString)
        gasPrice = (try? values.decode(String.self, forKey: .gasPrice)) ?? ""
        gas = (try? values.decode(String.self, forKey: .gas)) ?? ""
        gasUsed = (try? values.decode(String.self, forKey: .gasUsed)) ?? ""
        blockNumber = try values.decode(String.self, forKey: .blockNumber)

        if let string = try? values.decode(String.self, forKey: .value) {
            value = string
        } else if let number = try? values.decode(UInt.self, forKey: .value) {
            value = "\(number)"
        }

        if let value = try? values.decode(String.self, forKey: .chainName) {
            chainName = value
        } else if let value = try? values.decode(String.self, forKey: .tokenName) {
            chainName = value
        }

        if let value = try? values.decode(String.self, forKey: .tokenSymbol) {
            symbol = value
        }

        if let timestamp = try? values.decode(Int.self, forKey: .timestamp) {
            time = Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
        } else if let string = try? values.decode(String.self, forKey: .timeStamp) {
            if let timestamp = Double(string) {
                time = Date(timeIntervalSince1970: timestamp)
            }
        }
        if let date = time {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            formatTime = dateformatter.string(from: date)
        }

        let i_chainId = (try? values.decode(Int.self, forKey: .chainId)) ?? 0
        chainId = "\(i_chainId)"
    }
}

struct TransactionResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let count: UInt
        let transactions: [TransactionModel]
    }
}

struct NervosErc20TransactionResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let count: UInt
        let transfers: [TransactionModel]
    }
}

struct Erc20TransactionResponse: Decodable {
    let status: String
    let message: String
    let result: [TransactionModel]
}
