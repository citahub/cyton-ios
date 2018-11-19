//
//  TransactionHistoryService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import BigInt
import Web3swift
import EthereumAddress
import AppChain

class TransactionHistoryService {
    private let ethereumSymbol = " ETH"
    var transactions = [TransactionModel]()
    let token: TokenModel
    var quotaPrice: Double = pow(10, 9)
    var loading = false
    private var page = 1
    private let pageSize = 20

    var walletAddress: String {
        return WalletRealmTool.getCurrentAppModel().currentWallet!.address
    }

    fileprivate init(token: TokenModel) {
        self.token = token
    }

    static func service(with token: TokenModel) -> TransactionHistoryService {
        if token.type == .erc20 {
            return Erc20(token: token)
        } else if token.type == .ether {
            return Ethereum(token: token)
        } else if token.type == .appChain {
            return AppChain(token: token)
        } else if token.type == .appChainErc20 {
            return AppChainErc20(token: token)
        } else {
            fatalError()
        }
    }

    func reloadData(completion: @escaping (Error?) -> Void) {
        guard loading == false else { return }
        page = 1
        transactions = []
        loadMoreDate { (_, error) in
            completion(error)
        }
    }

    func loadMoreDate(completion: @escaping ([Int], Error?) -> Void) {
        guard loading == false else { return }
        loading = true
        loadData(page: page) { [weak self](transactions, error) in
            guard let self = self else { return }
            if let error = error {
                completion([], error)
                return
            }
            if transactions.count > 0 {
                self.loading = false
                self.page += 1
            }
            var insertions = [Int]()
            for idx in transactions.indices {
                insertions.append(self.transactions.count + idx)
            }
            self.transactions.append(contentsOf: transactions)
            completion(insertions, nil)
        }
    }

    func loadData(page: Int, completion: @escaping ([TransactionModel], Error?) -> Void) {
    }

    func getAppChainQuotaPrice() {
        // TODO: should use let but AppChain type conflicts with local AppChain...
        var appChain = AppChainNetwork.appChain()
        if let url = URL(string: token.chainHosts) {
            appChain = AppChainNetwork.appChain(url: url)
        }
        do {
            let quotaPrice = try Utils.getQuotaPrice(appChain: appChain)
            self.quotaPrice = Double(quotaPrice)
        } catch {
            self.quotaPrice = pow(10, 9)
        }
    }
}

extension TransactionHistoryService {
    private class AppChain: TransactionHistoryService {
        override init(token: TokenModel) {
            super.init(token: token)
            getAppChainQuotaPrice()
        }

        override func loadData(page: Int, completion: @escaping ([TransactionModel], Error?) -> Void) {
            let urlString = ServerApi.nervosTransactionURL + walletAddress.lowercased()
            let parameters: [String: Any] = [
                "page": page,
                "perPage": pageSize,
                "valueFormat": "decimal"
            ]
            Alamofire.request(urlString, method: .get, parameters: parameters).responseJSON { [weak self](response) in
                do {
                    guard let responseData = response.data else { throw TransactionError.requestfailed }
                    let nervosTransaction = try? JSONDecoder().decode(TransactionResponse.self, from: responseData)
                    guard let transactions = nervosTransaction?.result.transactions else { throw TransactionError.requestfailed }
                    var resultArr: [TransactionModel] = []
                    guard let self = self else { throw TransactionError.requestfailed }
                    for transaction in transactions {
                        transaction.gasUsed = "\(Double(UInt.fromHex(transaction.gasUsed)) / pow(10, 18) * self.quotaPrice)"
                        transaction.blockNumber = "\(UInt.fromHex(transaction.blockNumber))"
                        transaction.transactionType = TransactionType.AppChain.rawValue
                        transaction.symbol = self.token.symbol
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        resultArr.append(transaction)
                    }
                    completion(transactions, nil)
                } catch {
                    completion([], error)
                }
            }
        }

    }

    private class Ethereum: TransactionHistoryService {
        override func loadData(page: Int, completion: @escaping ([TransactionModel], Error?) -> Void) {
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
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON { [weak self](response) in
                do {
                    guard let responseData = response.data else { throw TransactionError.requestfailed }
                    print(String(bytes: responseData.bytes, encoding: .utf8) ?? "none")
                    let ethTransaction = try? JSONDecoder().decode(Erc20TransactionResponse.self, from: responseData)
                    guard let transactions = ethTransaction?.result else { throw TransactionError.requestfailed }
                    var resultArr: [TransactionModel] = []
                    guard let self = self else { throw TransactionError.requestfailed }
                    for transaction in transactions {
                        transaction.chainName = "Ethereum Mainnet"
                        let gasPriceBigNumber = BigUInt(Int(transaction.gasPrice)!)
                        transaction.gasPrice = Web3.Utils.formatToEthereumUnits(gasPriceBigNumber, toUnits: .Gwei, decimals: 8, fallbackToScientific: false) ?? ""
                        transaction.transactionType = TransactionType.ETH.rawValue
                        transaction.symbol = self.ethereumSymbol
                        let totleGasBigNumber = BigUInt(Double(transaction.gasUsed)! * Double(transaction.gasPrice)!)
                        transaction.totleGas = Web3.Utils.formatToEthereumUnits(totleGasBigNumber, toUnits: .eth, decimals: 8, fallbackToScientific: false) ?? ""
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        resultArr.append(transaction)
                    }
                    completion(resultArr, nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }

    private class Erc20: TransactionHistoryService {
        override func loadData(page: Int, completion: @escaping ([TransactionModel], Error?) -> Void) {
            let address = EthereumAddress.toChecksumAddress(token.address) ?? token.address
            let parameters: [String: Any] = [
                "module": "account",
                "action": "tokentx",
                "contractaddress": address,
                "address": walletAddress,
                "page": page,
                "offset": pageSize,
                "sort": "desc",
                "apikey": ServerApi.etherScanKey
            ]
            loading = true
            Alamofire.request("https://api.etherscan.io/api", method: .get, parameters: parameters).responseData { [weak self](response) in
                do {
                    guard let data = response.data, let self = self else { return }
                    let response = try JSONDecoder().decode(Erc20TransactionResponse.self, from: data)
                    var results = [TransactionModel]()
                    for transaction in response.result {
                        transaction.chainId = self.token.chainId
                        transaction.transactionType = TransactionType.ERC20.rawValue
                        let totleGasBigNumber = BigUInt(Int(transaction.gasUsed)! * Int(transaction.gasPrice)!)
                        transaction.totleGas = Web3.Utils.formatToEthereumUnits(totleGasBigNumber, toUnits: .eth, decimals: 8, fallbackToScientific: false) ?? ""
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        results.append(transaction)
                    }
                    completion(results, nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }

    private class AppChainErc20: TransactionHistoryService {
        override init(token: TokenModel) {
            super.init(token: token)
            getAppChainQuotaPrice()
        }

        override func loadData(page: Int, completion: @escaping ([TransactionModel], Error?) -> Void) {
            let tokenAddress = token.address
            let parameters: [String: Any] = [
                "address": tokenAddress,
                "account": walletAddress,
                "page": page,
                "perPage": pageSize
            ]
            Alamofire.request("https://microscope.cryptape.com:8888/api/erc20/transfers", method: .get, parameters: parameters).responseData { [weak self](response) in
                do {
                    guard let self = self else { throw TransactionError.requestfailed }
                    guard let responseData = response.data else { throw TransactionError.requestfailed }
                    print(String(bytes: responseData.bytes, encoding: .utf8)!)
                    let response = try JSONDecoder().decode(NervosErc20TransactionResponse.self, from: responseData)
                    var resultArr: [TransactionModel] = []
                    for transaction in response.result.transfers {
                        transaction.gasUsed = "\(Double(UInt.fromHex(transaction.gasUsed)) / pow(10, 18) * self.quotaPrice)"
                        transaction.blockNumber = "\(UInt.fromHex(transaction.blockNumber))"
                        transaction.transactionType = TransactionType.AppChainERC20.rawValue
                        transaction.symbol = self.token.symbol
                        transaction.value = Web3.Utils.formatToEthereumUnits(BigUInt(atof(transaction.value)), toUnits: .eth, decimals: 8, fallbackToScientific: false)!
                        resultArr.append(transaction)
                    }
                    completion(resultArr, nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }
}
