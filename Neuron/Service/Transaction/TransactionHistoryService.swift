//
//  TransactionHistoryService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import TrustCore
import Alamofire
import BigInt
import web3swift

class TransactionHistoryService {
    var transactions = [TransactionModel]()
    let token: TokenModel
    var walletAddress: String {
        return WalletRealmTool.getCurrentAppModel().currentWallet!.address
    }

    fileprivate init(token: TokenModel) {
        self.token = token
    }

    static func service(with token: TokenModel) -> TransactionHistoryService {
        if token.type == .erc20 {
            return Erc20(token: token)
        } else if token.type == .ethereum {
            return Ethereum(token: token)
        } else if token.type == .nervos {
            return Nervos(token: token)
        } else if token.type == .nervosErc20 {
            return NervosErc20(token: token)
        } else {
            fatalError()
        }
    }

    func reloadData(completion: @escaping (Error?) -> Void) {
    }

    func loadMoreDate(completion: @escaping ([Int], Error?) -> Void) {
    }
}

extension TransactionHistoryService {
    private class Nervos: TransactionHistoryService {
        override func reloadData(completion: @escaping (Error?) -> Void) {
            let urlString = ServerApi.nervosTransactionURL + walletAddress.lowercased()
            Alamofire.request(urlString, method: .get, parameters: nil).responseJSON { [weak self](response) in
                do {
                    guard let responseData = response.data else { throw TransactionError.requestfailed }
                    let nervosTransaction = try? JSONDecoder().decode(TransactionResponse.self, from: responseData)
                    guard let transactions = nervosTransaction?.result.transactions else { throw TransactionError.requestfailed }
                    var resultArr: [TransactionModel] = []
                    guard let self = self else { throw TransactionError.requestfailed }
                    for transaction in transactions {
                        transaction.gasUsed = "\(Double(UInt.fromHex(transaction.gasUsed)) / pow(10, 18))"
                        transaction.blockNumber = "\(UInt.fromHex(transaction.blockNumber))"
                        transaction.transactionType = "Nervos"
                        transaction.symbol = self.token.symbol
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        resultArr.append(transaction)
                    }
                    self.transactions = resultArr
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }

    private class Ethereum: TransactionHistoryService {
        override func reloadData(completion: @escaping (Error?) -> Void) {
            let parameters: Dictionary = ["address": walletAddress]
            Alamofire.request(ServerApi.etherScanURL, method: .get, parameters: parameters).responseJSON { [weak self](response) in
                do {
                    guard let responseData = response.data else { throw TransactionError.requestfailed }
                    print(String(bytes: responseData.bytes, encoding: .utf8) ?? "none")
                    let ethTransaction = try? JSONDecoder().decode(TransactionResponse.self, from: responseData)
                    guard let transactions = ethTransaction?.result.transactions else { throw TransactionError.requestfailed }
                    var resultArr: [TransactionModel] = []
                    guard let self = self else { throw TransactionError.requestfailed }
                    for transaction in transactions {
                        transaction.chainName = "Ethereum Mainnet"
                        let gasPriceBigNumber = BigUInt(Int(transaction.gasPrice)!)
                        transaction.gasPrice = Web3.Utils.formatToEthereumUnits(gasPriceBigNumber, toUnits: .Gwei, decimals: 8, fallbackToScientific: false) ?? ""
                        transaction.transactionType = "ETH"
                        transaction.symbol = "ETH"
                        let totleGasBigNumber = BigUInt(Int(transaction.gasUsed)! * Int(transaction.gasPrice)!)
                        transaction.totleGas = Web3.Utils.formatToEthereumUnits(totleGasBigNumber, toUnits: .eth, decimals: 8, fallbackToScientific: false) ?? ""
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        resultArr.append(transaction)
                    }
                    self.transactions = resultArr
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }

    private class Erc20: TransactionHistoryService {
        var loading = false
        private var page = 1

        override func reloadData(completion: @escaping (Error?) -> Void) {
            guard loading == false else { return }
            page = 1
            transactions = []
            loadData(page: page) { (_, error) in
                completion(error)
            }
        }

        override func loadMoreDate(completion: @escaping ([Int], Error?) -> Void) {
            guard loading == false else { return }
            loadData(page: page, completion: completion)
        }

        func loadData(page: Int, completion: @escaping ([Int], Error?) -> Void) {
            let address = TrustCore.EthereumAddress(string: token.address)?.eip55String ?? token.address
            let parameters: [String: Any] = [
                "module": "account",
                "action": "tokentx",
                "contractaddress": address,
                "address": walletAddress,
                "page": page,
                "offset": 20,
                "sort": "desc",
                "apikey": "T9GV1IF4V7YDXQ8F53U1FK2KHCE2KUUD8Z"
            ]
            loading = true
            Alamofire.request("https://api.etherscan.io/api", method: .get, parameters: parameters).responseData { [weak self](response) in
                do {
                    guard let data = response.data, let self = self else { return }
                    let response = try JSONDecoder().decode(Erc20TransactionResponse.self, from: data)
                    var results = [TransactionModel]()
                    var insertions = [Int]()
                    for transaction in response.result {
                        transaction.chainId = self.token.chainId
                        transaction.transactionType = "Erc20"
                        let totleGasBigNumber = BigUInt(Int(transaction.gasUsed)! * Int(transaction.gasPrice)!)
                        transaction.totleGas = Web3.Utils.formatToEthereumUnits(totleGasBigNumber, toUnits: .eth, decimals: 8, fallbackToScientific: false) ?? ""
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        insertions.append(results.count + self.transactions.count)
                        results.append(transaction)
                    }
                    self.transactions.append(contentsOf: results)
                    self.page += 1
                    self.loading = false
                    completion(insertions, nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }

    private class NervosErc20: TransactionHistoryService {
        var loading = false
        private var page = 1

        override func reloadData(completion: @escaping (Error?) -> Void) {
            guard loading == false else { return }
            page = 1
            transactions = []
            loadData(page: page) { (_, error) in
                completion(error)
            }
        }

        override func loadMoreDate(completion: @escaping ([Int], Error?) -> Void) {
            guard loading == false else { return }
            loadData(page: page, completion: completion)
        }

        func loadData(page: Int, completion: @escaping ([Int], Error?) -> Void) {
            let tokenAddress = token.address
            let parameters: [String: Any] = [
                "address": tokenAddress,
                "account": walletAddress,
                "page": page,
                "perPage": 20
            ]
            loading = true
            Alamofire.request("https://microscope.cryptape.com:8888/api/erc20/transfers", method: .get, parameters: parameters).responseData { [weak self](response) in
                do {
                    guard let self = self else { throw TransactionError.requestfailed }
                    guard let responseData = response.data else { throw TransactionError.requestfailed }
                    print(String(bytes: responseData.bytes, encoding: .utf8)!)
                    let response = try JSONDecoder().decode(NervosErc20TransactionResponse.self, from: responseData)
                    var resultArr: [TransactionModel] = []
                    var insertions = [Int]()
                    for transaction in response.result.transfers {
                        transaction.gasUsed = "\(Double(UInt.fromHex(transaction.gasUsed)) / pow(10, 18))"
                        transaction.blockNumber = "\(UInt.fromHex(transaction.blockNumber))"
                        transaction.transactionType = "NervosErc20"
                        transaction.symbol = self.token.symbol
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        insertions.append(resultArr.count + self.transactions.count)
                        resultArr.append(transaction)
                    }
                    self.transactions.append(contentsOf: resultArr)
                    self.page += 1
                    self.loading = false
                    completion(insertions, nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }
}
