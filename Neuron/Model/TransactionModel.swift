//
//  TransactionModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TransactionModel: NSObject, Decodable {
    var value = ""
    var from = ""
    var to = ""
    var hashString = ""
    var timeStamp = ""
    var chainName = ""
    var gasUsed = ""
    var gas = ""
    var gasPrice = ""
    var blockNumber = ""
    var symbol = ""
    var transactionType = "ETH" //default "ETH" include ERC20 transaction,  another one is "Nervos"
    var totleGas = ""
    var formatTime = ""

    var chainId = ""

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case hashString = "hash"
        case timeStamp = "timestamp"
        case gasPrice
        case gas
        case gasUsed
        case blockNumber
        case value
        case chainName
        case chainId
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
        value = try values.decode(String.self, forKey: .value)
        chainName = (try? values.decode(String.self, forKey: .chainName)) ?? ""

        let timestamp = try? values.decode(Int.self, forKey: .timeStamp)
        timeStamp = "\(timestamp ?? 0)"
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
