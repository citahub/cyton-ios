//
//  AppChainTransactionDetails.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt

class AppChainTransactionDetails: TransactionDetails {
    var content: String = ""
    var gasUsed: BigUInt = 0
    var quotaUsed: BigUInt = 0
    var chainId: Int = 0
    var chainName: String = ""
    var errorMessage: String?

    enum AppChainCodingKeys: String, CodingKey {
        case content
        case gasUsed
        case quotaUsed
        case chainId
        case chainName
        case errorMessage
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: AppChainCodingKeys.self)
        content = (try? values.decode(String.self, forKey: .content)) ?? ""
        if let value = try? values.decode(String.self, forKey: .gasUsed) {
            gasUsed = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .quotaUsed) {
            quotaUsed = BigUInt(string: value) ?? 0
        }
        chainId = (try? values.decode(Int.self, forKey: .chainId)) ?? 0
        chainName = (try? values.decode(String.self, forKey: .chainName)) ?? ""
    }
}
