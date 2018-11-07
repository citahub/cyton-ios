//
//  TransactionService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import Web3swift
import BigInt
import struct AppChain.TransactionSendingResult

typealias TxHash = String

protocol TransactionServiceDelegate: NSObjectProtocol {
    func transactionCompletion(_ transactionService: TransactionService, result: TransactionService.Result)
    func transactionGasCostChanged(_ transactionService: TransactionService)
}

class TransactionService {
    enum Result {
        case error(Error)
        case succee(TxHash)
    }

    weak var delegate: TransactionServiceDelegate?
    var token: TokenModel!
    var fromAddress: String!
    var tokenBalance: Double = 0.0
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
    var toAddress = ""
    var amount = 0.0
    var extraData = Data()
    var password: String = ""  // TODO: Inject web3 instance instead of passing password.
    var isUseQRCode = false    // TODO: Fix spelling.

    init(token: TokenModel) {
        self.token = token
        tokenBalance = Double(token.tokenBalance) ?? 0.0
    }

    static func service(with token: TokenModel) -> TransactionService {
        if token.type == .erc20 {
            return ERC20(token: token)
        } else if token.type == .ethereum {
            return Ethereum(token: token)
        } else if token.type == .nervos {
            return AppChain(token: token)
        } else if token.type == .nervosErc20 {
            return AppChainERC20(token: token)
        } else {
            fatalError()
        }
    }

    func requestGasCost() {
    }

    func sendTransaction() {
    }

    func completion(result: Result) {
        delegate?.transactionCompletion(self, result: result)
        trackEvent(result)
    }

    // TODO: move this out of Transaction Service.
    private func trackEvent(_ result: TransactionService.Result) {
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
                outcomeAddress: fromAddress,
                transactionType: .normal
            )
            if isUseQRCode {
                SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: true)
            }
        }
    }
}
extension TransactionService {
    class Ethereum: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let bigNumber = try EthereumNetwork().getWeb3().eth.getGasPrice()
                self.gasPrice = (bigNumber.words.first ?? 1) * 4
            } catch {
                self.gasPrice = 4
            }
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            // TODO: extract this
            let keystore = WalletManager.default.keystore(for: fromAddress)
            let web3 = EthereumNetwork().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            do {
                let sender = EthereumTxSender(web3: web3, from: fromAddress)
                let txhash = try sender.sendETH(
                    to: toAddress,
                    amount: String(amount),
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    data: extraData,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

extension TransactionService {
    class ERC20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let bigNumber = try EthereumNetwork().getWeb3().eth.getGasPrice()
                self.gasPrice = (bigNumber.words.first ?? 1) * 4
            } catch {
                self.gasPrice = 4
            }
            self.changeGasLimitEnable = true
            self.changeGasPriceEnable = true
        }

        override func sendTransaction() {
            // TODO: extract this
            let keystore = WalletManager.default.keystore(for: fromAddress)
            let web3 = EthereumNetwork().getWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))

            do {
                let sender = EthereumTxSender(web3: web3, from: fromAddress)
                // TODO: estimate gas
                let txhash = try sender.sendToken(
                    to: toAddress,
                    amount: "\(amount)",
                    gasLimit: gasLimit,
                    gasPrice: BigUInt(gasPrice),
                    erc20TokenAddress: token.address,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

extension TransactionService {
    class AppChain: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21_000
            do {
                let result = try Utils.getQuotaPrice(appChain: AppChainNetwork.appChain()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }

        override func sendTransaction() {
            // TODO: queue async
            super.sendTransaction()
            do {
                // TODO: pass in wallet and selected AppChain
                let sender = AppChainTxSender(appChain: AppChainNetwork.appChain(), walletManager: WalletManager.default, from: fromAddress)
                let txhash = try sender.send(
                    to: toAddress,
                    quota: BigUInt(UInt(gasLimit/* * gasPrice*/)),
                    data: extraData,
                    value: "\(amount)",
                    tokenHosts: token.chainHosts,
                    chainId: BigUInt(token.chainId)!,
                    password: password
                )
                self.completion(result: Result.succee(txhash))
            } catch let error {
                self.completion(result: Result.error(error))
            }
        }
    }
}

extension TransactionService {
    class AppChainERC20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 100_000
            do {
                let result = try Utils.getQuotaPrice(appChain: AppChainNetwork.appChain()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }
    }
}
