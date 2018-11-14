//
//  TransactionParamBuilder.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt

/// Prepare tx params.
class TransactionParamBuilder {
    var from: String!
    var to = ""
    var value: BigUInt = 0
    var data = Data()

    var gasPrice: BigUInt = 0 {
        didSet {
            rebuildGasCalculator()
        }
    }

    var gasLimit: UInt64 = 0 {
        didSet {
            rebuildGasCalculator()
        }
    }

    var txFee: BigUInt {
        return gasCalculator.txFee
    }

    var txFeeNatural: Double {
        return gasCalculator.txFeeNatural
    }

    var tokenBalance: BigUInt = 0

    /// Note: this returns true even when native token (ETH) is not enough for tx fee
    ///   when sending ERC20. UI layer should check that.
    var hasSufficientBalance: Bool {
        switch token.type {
        case .ethereum, .nervos:
            return tokenBalance >= txFee + value
        case .erc20, .nervosErc20:
            return tokenBalance >= value
        }
    }

    private var token: TokenModel!
    private var gasCalculator = GasCalculator(gasPrice: GasCalculator.defaultGasPrice, gasLimit: 21_000)

    init(token: TokenModel) {
        self.token = token
        tokenBalance = BigUInt(token.tokenBalance)! * BigUInt(10).power(token.decimals)

        fetchGasPrice()
    }

    private func fetchGasPrice() {
        let fetched = { [weak self] price -> Void in
            DispatchQueue.main.async {
                self?.gasPrice = price
                // TODO: notify observer?
            }
        }

        DispatchQueue.global().async {
            switch self.token.type {
            case .ethereum, .erc20:
                GasPriceFetcher().fetchGasPrice(then: fetched)
            case .nervos, .nervosErc20:
                GasPriceFetcher().fetchQuotaPrice(rpcNode: self.token.chainHosts, then: fetched)
            }
        }
    }

    private func rebuildGasCalculator() {
        gasCalculator = GasCalculator(gasPrice: gasPrice, gasLimit: gasLimit)
    }
}

/*
extension TransactionParamBuilder {
    class Ethereum: TransactionParamBuilder {

        override func sendTransaction(password: String) {
            // TODO: extract this
            let keystore = WalletManager.default.keystore(for: from)
            let web3 = EthereumNetwork().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            do {
                // TODO: change amount to string which matches UI input exactly.
                guard let value = Web3.Utils.parseToBigUInt(String(amount), units: .eth) else {
                    throw SendTransactionError.invalidAmountFormat
                }

                let sender = try EthereumTxSender(web3: web3, from: from)
                let txhash = try sender.sendETH(
                    to: to,
                    value: value,
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    data: data,
                    password: password
                )
                // TODO
            } catch let error {
                // TODO
            }
        }
    }
}

extension TransactionParamBuilder {
    class ERC20: TransactionParamBuilder {

        override func sendTransaction(password: String) {
            let keystore = WalletManager.default.keystore(for: from)
            let web3 = EthereumNetwork().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            do {
                // TODO: Get token decimal and convert
                guard let value = Web3.Utils.parseToBigUInt(String(amount), units: .eth) else {
                    throw SendTransactionError.invalidAmountFormat
                }

                let sender = try EthereumTxSender(web3: web3, from: from)
                // TODO: estimate gas
                let txhash = try sender.sendToken(
                    to: toAddress,
                    value: value,
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    contractAddress: token.address,
                    password: password
                )
                // TODO
            } catch let error {
                // TODO
            }
        }
    }
}

extension TransactionParamBuilder {
    class AppChain: TransactionParamBuilder {

        override func sendTransaction(password: String) {
            super.sendTransaction(password: password)
            do {
                guard let appChainUrl = URL(string: token.chainHosts) else {
                    throw SendTransactionError.invalidAppChainNode
                }
                guard let value = Web3Utils.parseToBigUInt(String(amount), units: .eth) else {
                    throw SendTransactionError.invalidAmountFormat
                }
                let sender = try AppChainTxSender(appChain: AppChainNetwork.appChain(url: appChainUrl), walletManager: WalletManager.default, from: fromAddress)
                let txhash = try sender.send(
                    to: toAddress,
                    value: value,
                    quota: gasLimit,
                    data: data,
                    chainId: BigUInt(token.chainId)!,
                    password: password
                )
                // TODO
            } catch let error {
                // TODO
            }
        }
    }
}
 */
