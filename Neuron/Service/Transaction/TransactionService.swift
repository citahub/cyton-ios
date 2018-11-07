//
//  TransactionService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt
import web3swift
import struct AppChain.TransactionSendingResult

protocol TransactionServiceDelegate: NSObjectProtocol {
    func transactionCompletion(_ transactionService: TransactionService, result: TransactionService.Result)
    func transactionGasCostChanged(_ transactionService: TransactionService)
}

class TransactionService {
    enum Result {
        case error(Error)
        case ethereum(web3swift.TransactionSendingResult)
        case appChain(TransactionSendingResult)
    }
    enum Error: String, Swift.Error {
        case cancel = ""
        case prepareFailed
        case sendFailed
    }

    weak var delegate: TransactionServiceDelegate?
    var token: TokenModel!
    var wallet: WalletModel!
    var tokenBalance: Double = 0.0
    var estimatedGasPrice: UInt = 1 {
        didSet {
            gasPrice = estimatedGasPrice
        }
    }
    var gasPrice: UInt = 1 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(gasLimit * gasPrice), toUnits: .eth, decimals: 10) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasLimit: UInt = 0 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(gasLimit * gasPrice), toUnits: .eth, decimals: 10) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasCost: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.transactionGasCostChanged(self)
            }
        }
    }
    var gasCostAmount: Double = 0.0
    var changeGasLimitEnable = false
    var changeGasPriceEnable = false
    var isSupportGasSetting: Bool { return changeGasPriceEnable || changeGasLimitEnable }
    var fromAddress: String { return wallet.address }
    var toAddress = ""
    var amount = 0.0
    var extraData = Data()
    var password: String = ""
    var isUseQRCode = false

    fileprivate init(token: TokenModel) {
        self.token = token
        tokenBalance = Double(token.tokenBalance) ?? 0.0
        wallet = WalletRealmTool.getCurrentAppModel().currentWallet!
    }

    static func service(with token: TokenModel) -> TransactionService {
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

    func requestGasCost() {
    }

    func sendTransaction() {
    }

    func completion(result: Result) {
        switch result {
        case .error:
            if isUseQRCode {
                SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: false)
            }
        default:
            SensorsAnalytics.Track.transaction(
                chainType: token.chainId,
                currencyType: token.symbol,
                currencyNumber: amount,
                receiveAddress: toAddress,
                outcomeAddress: wallet.address,
                transactionType: .normal
            )
            if isUseQRCode {
                SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: true)
            }
        }
        delegate?.transactionCompletion(self, result: result)
    }
}

extension TransactionService {
    class Nervos: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            let result = Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).value
            self.estimatedGasPrice = result?.words.first ?? 1
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }

        override func sendTransaction() {
            super.sendTransaction()
            let amountText = String(format: "%lf", amount)
            NervosTransactionService().prepareNervosTransactionForSending(
                address: toAddress,
                quota: BigUInt(UInt(gasLimit/* * gasPrice*/)),
                data: extraData,
                value: amountText,
                tokenHosts: token.chainHosts,
                chainId: BigUInt(token.chainId)!) { (result) in
                switch result {
                case .success(let transaction):
                    NervosTransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                        switch result {
                        case .success(let result):
                            self.completion(result: Result.appChain(result))
                        case .error:
                            self.completion(result: Result.error(.sendFailed))
                        }
                    })
                case .error:
                    self.completion(result: Result.error(.prepareFailed))
                }
            }
        }
    }
}

extension TransactionService {
    class Erc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000 * 4
            let bigNumber = Web3Network().getWeb3().eth.getGasPrice().value
            self.estimatedGasPrice = (bigNumber?.words.first ?? 1)
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            ERC20TransactionService().prepareERC20TransactionForSending(
                destinationAddressString: toAddress,
                amountString: "\(amount)",
                gasLimit: gasLimit,
                gasPrice: BigUInt(gasPrice),
                erc20TokenAddress: token.address) { (result) in
                switch result {
                case .success(let transaction):
                    ERC20TransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                        switch result {
                        case .success(let result):
                            self.completion(result: Result.ethereum(result))
                        case .error:
                            self.completion(result: Result.error(.sendFailed))
                        }
                    })
                case .error:
                    self.completion(result: Result.error(.prepareFailed))
                }
            }
        }
    }
}

extension TransactionService {
    class Ethereum: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            let bigNumber = Web3Network().getWeb3().eth.getGasPrice().value
            self.estimatedGasPrice = bigNumber?.words.first ?? 1
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            EthTransactionService().prepareETHTransactionForSending(
                destinationAddressString: toAddress,
                amountString: "\(amount)",
                gasLimit: gasLimit,
                gasPrice: BigUInt(gasPrice),
                data: extraData) { (result) in
                switch result {
                case .success(let transaction):
                    EthTransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                        switch result {
                        case .success(let result):
                            self.completion(result: Result.ethereum(result))
                        case .error:
                            self.completion(result: Result.error(.sendFailed))
                        }
                    })
                case .error:
                    self.completion(result: Result.error(.prepareFailed))
                }
            }
        }
    }
}

extension TransactionService {
    class NervosErc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 100000
            let result = Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).value
            self.estimatedGasPrice = result?.words.first ?? 1
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }
    }
}
