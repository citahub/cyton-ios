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

protocol TransactionServiceDelegate: NSObjectProtocol {
    func transactionCompletion(_ transactionService: TransactionService, error: Error?)
    func transactionGasCostChanged(_ transactionService: TransactionService)
}

class TransactionService {
    weak var delegate: TransactionServiceDelegate?
    var token: TokenModel!
    var wallet: WalletModel!
    var tokenBalance: Double = 0.0
    var gasPrice: UInt = 1 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(gasLimit * gasPrice), toUnits: .eth, decimals: 20) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasLimit: UInt = 0 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(gasLimit * gasPrice), toUnits: .eth, decimals: 20) ?? ""
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

    func success() {
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
        delegate?.transactionCompletion(self, error: nil)
    }

    func failure(error: Error) {
        delegate?.transactionCompletion(self, error: error)
        if isUseQRCode {
            SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: false)
        }
    }
}

extension TransactionService {
    class Nervos: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            do {
                let result = try Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }

        override func sendTransaction() {
            super.sendTransaction()
            NervosTransactionService().prepareNervosTransactionForSending(
                address: toAddress,
                quota: BigUInt(UInt(gasLimit * gasPrice)),
                data: extraData,
                value: "\(amount)",
                tokenHosts: token.chainHosts,
                chainId: BigUInt(token.chainId)!) { (result) in
                switch result {
                case .success(let transaction):
                    NervosTransactionService().send(password: self.password, transaction: transaction, completion: { (result) in
                        switch result {
                        case .success:
                            self.success()
                        case .error(let error):
                            self.failure(error: error)
                        }
                    })
                case .error(let error):
                    self.failure(error: error)
                }
            }
        }
    }
}

extension TransactionService {
    class Ethereum: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            let bigNumber = try? Web3Network().getWeb3().eth.getGasPrice().dematerialize()
            self.gasPrice = (bigNumber?.words.first ?? 1) * 4
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
                        case .success:
                            self.success()
                        case .error(let error):
                            self.failure(error: error)
                        }
                    })
                case .error(let error):
                    self.failure(error: error)
                }
            }
        }
    }
}

extension TransactionService {
    class Erc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 21000
            let bigNumber = try? Web3Network().getWeb3().eth.getGasPrice().dematerialize()
            self.gasPrice = (bigNumber?.words.first ?? 1) * 4
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
                        case .success:
                            self.success()
                        case .error(let error):
                            self.failure(error: error)
                        }
                    })
                case .error(let error):
                    self.failure(error: error)
                }
            }
        }
    }
}

extension TransactionService {
    class NervosErc20: TransactionService {
        override func requestGasCost() {
            self.gasLimit = 100000
            do {
                let result = try Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).dematerialize()
                self.gasPrice = result.words.first ?? 1
            } catch {
                self.gasPrice = 1
            }
            self.changeGasLimitEnable = false
            self.changeGasPriceEnable = false
        }
    }
}
