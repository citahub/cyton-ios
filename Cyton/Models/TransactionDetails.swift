//
//  TransactionDetails.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

enum TransactionState: Int {
    case pending
    case success
    case failure
}

enum TransactionHistoryError: Error {
    case networkFailure
}

class TransactionDetails: Codable {
    var hash = ""
    var to = ""
    var from = ""
    var value: BigUInt = 0
    var date = Date()
    var blockNumber: BigUInt = 0
    var status: TransactionState = .success
    var token: Token!
    var gasPrice: BigUInt = 0
    var gasLimit: BigUInt = 0

    enum CodingKeys: String, CodingKey {
        case hash
        case from
        case to
        case value
        case timestamp
        case blockNumber
    }

    init() {
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hash = (try? values.decode(String.self, forKey: .hash)) ?? ""
        from = (try? values.decode(String.self, forKey: .from)) ?? ""
        to = (try? values.decode(String.self, forKey: .to)) ?? ""
        if let value = try? values.decode(UInt.self, forKey: .value) {
            self.value = BigUInt(value)
        } else if let value = try? values.decode(String.self, forKey: .value) {
            self.value = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(TimeInterval.self, forKey: .timestamp) {
            date = Date(timeIntervalSince1970: value / 1000.0)
        }
        if let value = try? values.decode(String.self, forKey: .blockNumber) {
            if value.hasPrefix("0x") {
                blockNumber = BigUInt(value.removeHexPrefix(), radix: 16) ?? 0
            } else {
                blockNumber = BigUInt(value) ?? 0
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hash, forKey: .hash)
        try container.encode(to, forKey: .to)
        try container.encode(from, forKey: .from)
        try container.encode("0x\(String(value, radix: 16))", forKey: .value)
        try container.encode(date.timeIntervalSince1970, forKey: .timestamp)
        try container.encode("0x\(String(blockNumber, radix: 16))", forKey: .blockNumber)
    }
}

extension TransactionDetails {
    var isContractCreation: Bool {
        return to.count == 0
    }
}
