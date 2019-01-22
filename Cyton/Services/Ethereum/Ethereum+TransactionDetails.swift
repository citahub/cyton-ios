//
//  Ethereum+TransactionDetails.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import BigInt
import PromiseKit

// MARK: - Ethereum transaction details
class EthereumTransactionDetails: TransactionDetails {
    var nonce: BigUInt = 0
    var blockHash: String = ""
    var transactionIndex: BigUInt = 0
    var gas: BigUInt = 0
    var gasUsed: BigUInt = 0
    var input: String = ""
    var contractAddress: String = ""
    var cumulativeGasUsed: BigUInt = 0
    var confirmations: UInt = 0

    var isError = false
    var txreceipt_status: Int = 0

    var tokenName: String = ""
    var tokenSymbol: String = ""
    var tokenDecimal: String = ""

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

        case tokenName
        case tokenSymbol
        case tokenDecimal
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

        if let value = try? values.decode(String.self, forKey: .isError) {
            isError = Bool(value) ?? false
        }
        if let value = try? values.decode(String.self, forKey: .txreceipt_status) {
            txreceipt_status = Int(value) ?? 0
        }

        tokenName = (try? values.decode(String.self, forKey: .tokenName)) ?? ""
        tokenSymbol = (try? values.decode(String.self, forKey: .tokenSymbol)) ?? ""
        tokenDecimal = (try? values.decode(String.self, forKey: .tokenDecimal)) ?? ""
    }
}

private struct EthereumTransactionsResponse: Decodable {
    let status: String
    let message: String
    let result: [EthereumTransactionDetails]
}

// MARK: - Get transaction details
extension EthereumNetwork {
    func getTransactionHistory(walletAddress: String, page: UInt, pageSize: UInt) throws -> [EthereumTransactionDetails] {
        let url = EthereumNetwork().apiHost().appendingPathComponent("/api")
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
        let url = EthereumNetwork().apiHost().appendingPathComponent("/api")
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

    func getTransaction(txhash: String) throws -> EthereumTransactionDetails {
        let url = EthereumNetwork().apiHost().appendingPathComponent("/api")
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
