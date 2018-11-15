//
//  AppChainTransactionHistory.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import Alamofire
import AppChain
import PromiseKit

private struct AppChainTransactionsResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let count: UInt
        let transactions: [AppChainTransactionDetails]
    }
}

private struct AppChainTransactionResponse: Decodable {
    let result: Result
    struct Result: Decodable {
        let transaction: AppChainTransactionDetails?
    }
}

class AppChainTransactionHistory {
    func getTransactionHistory(walletAddress: String, page: UInt, pageSize: UInt) throws -> [AppChainTransactionDetails] {
        let url = "https://microscope.cryptape.com:8888/api/transactions"
        let parameters: [String: Any] = [
            "account": walletAddress.lowercased(),
            "page": page,
            "perPage": pageSize,
            "valueFormat": "decimal"
        ]
        return try Promise<[AppChainTransactionDetails]>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(AppChainTransactionsResponse.self, from: responseData)
                    let transactions = response.result.transactions
                    resolver.fulfill(transactions)
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }

    func getErc20TransactionHistory(walletAddress: String, tokenAddress: String, page: UInt, pageSize: UInt) throws -> [AppChainErc20TransactionDetails] {
        return []
    }

    func getTransaction(txhash: String, account: String, from: String, to: String) throws -> AppChainTransactionDetails {
        let url = "https://microscope.cryptape.com:8888/api/transactions/\(txhash)"
        let parameters: [String: Any] = [
            "account": account,
            "from": from,
            "to": to
        ]
        return try Promise<AppChainTransactionDetails>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseData(completionHandler: { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(AppChainTransactionResponse.self, from: responseData)
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
