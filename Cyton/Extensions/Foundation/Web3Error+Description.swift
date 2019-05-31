//
//  Web3Error+Description.swift
//  Cyton
//
//  Created by 翟泉 on 2019/1/17.
//  Copyright © 2019 Cryptape. All rights reserved.
//

import UIKit
import web3swift

extension Web3Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .transactionSerializationError:
            return "Transaction Serialization Error"
        case .connectionError:
            return "Connection Error"
        case .dataError:
            return "Data Error"
        case .walletError:
            return "Wallet Error"
        case .inputError(let desc):
            return desc
        case .nodeError(let desc):
            return desc
        case .processingError(let desc):
            return desc
        case .keystoreError(let err):
            return err.localizedDescription
        case .generalError(let err):
            return err.localizedDescription
        case .unknownError:
            return "Unknown Error"
        }
    }
}
