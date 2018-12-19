//
//  TransactionDetailsParamBuilder.swift
//  Neuron
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
        tokenIcon = tx.token.iconUrl ?? ""
        switch tx.status {
        case .success:
            status = tx.isContractCreation ? "Transaction.Details.contractCreationSuccess".localized() : "TransactionStatus.success".localized()
            if tx.token.type == .appChain || tx.token.type == .appChainErc20 {
                if tx.token.chainId == "1" {
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
        amount = tx.value.toAmountText(tx.token.decimals) + " " + tx.token.symbol
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
            network = EthereumNetwork().currentNetwork.chainName
        case .appChain, .appChainErc20:
            network = tx.token.chainName ?? "CITA"
        }
    }

    func buildTxFee() {
        if tx.status == .success || tx.status == .pending {
            if let erc20 = tx as? Erc20TransactionDetails {
                txFee = (erc20.gasUsed * erc20.gasPrice).toAmountText() + " ETH"
                gasPrice = "\(erc20.gasPrice.toGweiText()) Gwei"
            } else if let ethereum = tx as? EthereumTransactionDetails {
                txFee = (ethereum.gasUsed * ethereum.gasPrice).toAmountText(tx.token.decimals) + " ETH"
                gasPrice = "\(ethereum.gasPrice.toGweiText()) Gwei"
            } else if let appChainErc20 = tx as? AppChainErc20TransactionDetails {
                let quotaPrice = GasPriceFetcher().quotaPrice(rpcNode: tx.token.chainHosts)
                gasPrice = "\(quotaPrice.toAmountText()) NATT"
                txFee = (appChainErc20.quotaUsed * quotaPrice).toAmountText() + " NATT"
            } else if let appChain = tx as? AppChainTransactionDetails {
                let quotaPrice = GasPriceFetcher().quotaPrice(rpcNode: tx.token.chainHosts)
                gasPrice = "\(quotaPrice.toAmountText(tx.token.decimals)) NATT"
                txFee = (appChain.quotaUsed * quotaPrice).toAmountText(tx.token.decimals) + " NATT"
            }
        }
        gasLimit = tx.status == .pending ? "\(tx.gasLimit)" : nil
        if tx.status == .success {
            if let ethereum = tx as? EthereumTransactionDetails {
                gasUsed = "\(ethereum.gasUsed)"
            } else if let erc20 = tx as? Erc20TransactionDetails {
                gasUsed = "\(erc20.gasUsed)"
            } else if let appChain = tx as? AppChainTransactionDetails {
                gasUsed = "\(appChain.quotaUsed)"
            } else if let appChainErc20 = tx as? AppChainErc20TransactionDetails {
                gasUsed = "\(appChainErc20.quotaUsed)"
            }
        }
    }
}
