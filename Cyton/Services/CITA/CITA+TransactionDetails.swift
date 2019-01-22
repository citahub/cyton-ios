//
//  CITA+TransactionDetails.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import Alamofire
import CITA
import PromiseKit

class CITATransactionDetails: TransactionDetails {
    var gasUsed: BigUInt = 0
    var quotaUsed: BigUInt = 0
    var chainId: Int = 0
    var chainName: String = ""
    var errorMessage: String?

    enum CITACodingKeys: String, CodingKey {
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
        let values = try decoder.container(keyedBy: CITACodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .gasUsed) {
            gasUsed = BigUInt(string: value) ?? 0
        }
        if let value = try? values.decode(String.self, forKey: .quotaUsed) {
            quotaUsed = BigUInt(string: value) ?? 0
        }
        chainName = (try? values.decode(String.self, forKey: .chainName)) ?? ""
        chainId = (try? values.decode(Int.self, forKey: .chainId)) ?? 0
        errorMessage = try? values.decode(String.self, forKey: .errorMessage)
        if errorMessage != nil {
            status = .failure
        }
    }
}

private struct CITATransactionsResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let count: UInt
        let transactions: [CITATransactionDetails]
    }
}

private struct CITATransactionResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let transaction: CITATransactionDetails?
    }
}

private struct CITAErc20TransactionsResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let transfers: [CITATransactionDetails]
    }
}

extension CITANetwork {
    func getTransactionHistory(walletAddress: String, page: UInt, pageSize: UInt) throws -> [CITATransactionDetails] {
        let url = host().appendingPathComponent("/api/transactions")
        let parameters: [String: Any] = [
            "account": walletAddress.lowercased(),
            "page": page,
            "perPage": pageSize
        ]
        return try Promise<[CITATransactionDetails]>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(CITATransactionsResponse.self, from: responseData)
                    let transactions = response.result.transactions
                    resolver.fulfill(transactions)
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }

    func getErc20TransactionHistory(walletAddress: String, tokenAddress: String, page: UInt, pageSize: UInt) throws -> [CITATransactionDetails] {
        let url = host().appendingPathComponent("/api/erc20/transfers")
        let parameters: [String: Any] = [
            "account": walletAddress.lowercased(),
            "address": tokenAddress,
            "page": page,
            "perPage": pageSize
        ]
        return try Promise<[CITATransactionDetails]>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(CITAErc20TransactionsResponse.self, from: responseData)
                    let transactions = response.result.transfers
                    resolver.fulfill(transactions)
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }

    func getTransaction(txhash: String) throws -> CITATransactionDetails {
        let url = host().appendingPathComponent("/api/transactions/\(txhash)")
        return try Promise<CITATransactionDetails>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: nil).responseData(completionHandler: { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(CITATransactionResponse.self, from: responseData)
                    if let transaction = response.result.transaction {
                        resolver.fulfill(transaction)
                    } else {
                        throw TransactionHistoryError.networkFailure
                    }
                } catch {
                    resolver.reject(error)
                }
            })
        }.wait()
    }
}
