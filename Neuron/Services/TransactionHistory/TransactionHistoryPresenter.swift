//
//  TransactionHistoryPresenter.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionHistoryPresenter: NSObject, TransactionStatusManagerDelegate {
    private(set) var transactions = [TransactionDetails]()
    let token: TokenModel

    init(token: TokenModel) {
        self.token = token
        walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        tokenAddress = token.address
        tokenType = token.type
        super.init()
    }

    private var hasMoreData = true

    func reloadData(completion: @escaping ([Int], Error?) -> Void) {
        guard loading == false else { return }
        page = 1
        hasMoreData = true
        loadMoreData(completion: completion)
    }

    func loadMoreData(completion: @escaping ([Int], Error?) -> Void) {
        guard loading == false else { return }
        guard hasMoreData else { return }
        loading = true
        DispatchQueue.global().async {
            do {
                let list = try self.loadData()
                self.hasMoreData = list.count == self.pageSize
                self.loading = false
                self.page == 1 ? self.transactions = [] : nil
                self.page += 1
                var insertions = [Int]()
                for idx in list.indices {
                    insertions.append(self.transactions.count + idx)
                }
                self.transactions.append(contentsOf: list)
                DispatchQueue.main.async {
                    completion(insertions, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }

    // MARK: -
    private var loading = false
    private var page: UInt = 1
    private var pageSize: UInt = 10
    private let walletAddress: String
    private let tokenAddress: String
    private let tokenType: TokenModel.TokenType

    private func loadData() throws -> [TransactionDetails] {
        switch tokenType {
        case .nervos:
            return try AppChainTransactionHistory().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .ethereum:
            return try EthereumTransactionHistory().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .erc20:
            return try EthereumTransactionHistory().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        case .nervosErc20:
            return try AppChainTransactionHistory().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        }
    }

    // MARK: - TransactionStatusManagerDelegate
    func transaction(transaction: TransactionDetails, didChangeStatus: TransactionState) {

    }
}
