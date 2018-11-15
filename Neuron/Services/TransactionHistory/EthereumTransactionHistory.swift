//
//  EthereumTransactionHistory.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import Alamofire
import BigInt
import PromiseKit

private struct EthereumTransactionsResponse: Decodable {
    let status: String
    let message: String
    let result: [EthereumTransactionDetails]
}

class EthereumTransactionHistory {
    func getTransactionHistory(walletAddress: String, page: UInt, pageSize: UInt) throws -> [EthereumTransactionDetails] {
        let url = EthereumNetwork().host().appendingPathComponent("/api")
        let parameters: [String: Any] = [
            "apikey": ServerApi.etherScanKey,
            "module": "account",
            "action": "txlist",
            "sort": "desc",
            "address": walletAddress,
            "page": page,
            "offset": pageSize
        ]
        return try Promise<[EthereumTransactionDetails]>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(EthereumTransactionsResponse.self, from: responseData)
                    let transactions = response.result
                    resolver.fulfill(transactions)
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }

    func getErc20TransactionHistory(walletAddress: String, tokenAddress: String, page: UInt, pageSize: UInt) throws -> [EthereumTransactionDetails] {
        let url = EthereumNetwork().host().appendingPathComponent("/api")
        let parameters: [String: Any] = [
            "apikey": ServerApi.etherScanKey,
            "module": "account",
            "action": "tokentx",
            "sort": "desc",
            "contractaddress": tokenAddress,
            "address": walletAddress,
            "page": page,
            "offset": pageSize
        ]
        return try Promise<[EthereumTransactionDetails]>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(EthereumTransactionsResponse.self, from: responseData)
                    let transactions = response.result
                    resolver.fulfill(transactions)
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }

//    https://api.etherscan.io/api?module=account&action=txlistinternal&txhash=0x40eb908387324f2b575b4879cd9d7188f69c8fc9d87c901b9e2daaea4b442170&apikey=YourApiKeyToken
//    https://api.etherscan.io/api?module=account&action=txlistinternal&txhash=0x9761013a4e29bc1d7f793663bda176f021381e06f70f2a0ad1d8464a304356b2&apikey=T9GV1IF4V7YDXQ8F53U1FK2KHCE2KUUD8Z
    func getTransaction(txhash: String) throws -> EthereumTransactionDetails {
        let url = EthereumNetwork().host().appendingPathComponent("/api")
        let parameters: [String: Any] = [
            "apikey": ServerApi.etherScanKey,
            "module": "account",
            "action": "txlistinternal",
            "txhash": txhash
        ]
        return try Promise<EthereumTransactionDetails>.init { (resolver) in
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw TransactionHistoryError.networkFailure }
                    let response = try JSONDecoder().decode(EthereumTransactionsResponse.self, from: responseData)
                    if let transaction = response.result.first {
                        resolver.fulfill(transaction)
                    } else {
                        resolver.reject(TransactionHistoryError.networkFailure)
                    }
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }
}
