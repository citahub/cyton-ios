//
//  TransactionDetailsParamBuilder.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/18.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionDetailsParamBuilder {
    let tx: TransactionDetails
    var tokenIcon: String!
    var status: String!
    var amount: String!
    var date: String!
    var from: String!
    var to: String!
    var txDetailsUrl: URL!
    var hash: String!
    var network: String!
    var block: String!
    var txFee: String!
    var gasPrice: String!
    var gasLimit: String!
    var gasUsed: String!

    init(tx: TransactionDetails) {
        self.tx = tx
        buildBaseInfo()
        buildTxFee()
        buildMoreInfo()
    }

    func buildBaseInfo() {
        tokenIcon = tx.token.iconUrl
        switch tx.status {
        case .success:
            status = tx.isContractCreation ? "Transaction.Details.contractCreationSuccess".localized() : "TransactionStatus.success".localized()
            if tx.token.type == .cita || tx.token.type == .citaErc20 {
                if tx.token.chainId == "1" || tx.token.chainId == "0x1" {
                    txDetailsUrl = URL(string: "https://microscope.cryptape.com/#/transaction/\(tx.hash)")!
                }
            } else {
                txDetailsUrl = EthereumNetwork().host().appendingPathComponent("/tx/\(tx.hash)")
            }
        case .pending:
            status = tx.isContractCreation ? "Transaction.Details.contractCreationPending".localized() : "TransactionStatus.pending".localized()
        case .failure:
            status = tx.isContractCreation ? "Transaction.Details.contractCreationFailure".localized() : "TransactionStatus.failure".localized()
        }

        if tx.from.lowercased() == tx.token.walletAddress.lowercased() ||
            tx.from == tx.to {
            amount = "-\(tx.value.toAmountText(tx.token.decimals)) \(tx.token.symbol)"
        } else {
            amount = "+\(tx.value.toAmountText(tx.token.decimals)) \(tx.token.symbol)"
        }

        date = {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            return dateformatter.string(from: tx.date)
        }()
        from = tx.from
        to = tx.to.count > 0 ? tx.to : "Contract Created"
    }

    func buildMoreInfo() {
        if tx.status == .success {
            hash = tx.hash
            block = "\(tx.blockNumber)"
        }
        switch tx.token.type {
        case .ether, .erc20:
            network = EthereumNetwork().networkType.chainName
        case .cita, .citaErc20:
            network = tx.token.chainName
        }
    }

    func buildTxFee() {
        if tx.status == .success || tx.status == .pending {
            if let etherTx = tx as? EthereumTransactionDetails {
                txFee = (etherTx.gasUsed * etherTx.gasPrice).toAmountText() + " ETH"
                gasPrice = "\(etherTx.gasPrice.toGweiText()) Gwei"
            } else if let citaTx = tx as? CITATransactionDetails {
                let quotaPrice = GasPriceFetcher().quotaPrice(rpcNode: citaTx.token.chainHost)
                gasPrice = "\(quotaPrice.toAmountText()) CTT"
                txFee = ((citaTx.quotaUsed > 0 ? citaTx.quotaUsed : citaTx.gasLimit) * quotaPrice).toAmountText() + " CTT"
            }
        }
        gasLimit = tx.status == .pending ? "\(tx.gasLimit)" : nil
        if tx.status == .success {
            if let etherTx = tx as? EthereumTransactionDetails {
                gasUsed = "\(etherTx.gasUsed)"
            } else if let citaTx = tx as? CITATransactionDetails {
                gasUsed = "\(citaTx.quotaUsed)"
            }
        }
    }
}
