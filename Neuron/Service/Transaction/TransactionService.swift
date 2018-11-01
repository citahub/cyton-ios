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
import TrustCore

protocol TransactionServiceDelegate: NSObjectProtocol {
    func transactionCompletion(_ transactionService: TransactionService)
}

class TransactionService {
    weak var delegate: TransactionServiceDelegate?
    var token: TokenModel!
    var wallet: WalletModel!

    var tokenBalance: Double = 0.0
    var gasPrice: Double = 0.0 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(UInt(gasLimit * gasPrice)), toUnits: .Gwei, decimals: 20) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasLimit: Double = 0.0 {
        didSet {
            let result = Web3Utils.formatToEthereumUnits(BigUInt(UInt(gasLimit * gasPrice)), toUnits: .Gwei, decimals: 20) ?? ""
            gasCost = Double(result) ?? 0.0
        }
    }
    var gasCost: Double = 0.0
    var gasCostAmount: Double = 0.0
    var changeGasLimitEnable = false
    var changeGasPriceEnable = false
    var isSupportGasSetting: Bool {
        return changeGasPriceEnable || changeGasLimitEnable
    }
    var fromAddress: String {
        return wallet.address
    }
    var toAddress = ""
    var amount = 0.0
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

    func sendTransaction() {
        Toast.showHUD()
    }

    func success() {
        Toast.hideHUD()
        Toast.showToast(text: "转账成功,请稍后刷新查看")
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
        delegate?.transactionCompletion(self)
    }

    func failure(error: Error) {
        Toast.hideHUD()
        Toast.showToast(text: error.localizedDescription)
        if isUseQRCode {
            SensorsAnalytics.Track.scanQRCode(scanType: .walletAddress, scanResult: false)
        }
    }
}

extension TransactionService {
    class Nervos: TransactionService {
        override init(token: TokenModel) {
            super.init(token: token)
            gasLimit = 21000
            do {
                let result = try Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).dematerialize()
                gasPrice = Double(result.words.first ?? 1)
            } catch {
                gasPrice = 1.0
            }
            changeGasLimitEnable = false
            changeGasPriceEnable = false
        }

        override func sendTransaction() {
            super.sendTransaction()
            NervosTransactionService().prepareNervosTransactionForSending(
                address: toAddress,
                quota: BigUInt(UInt(gasLimit * gasPrice)),
                data: Data(),
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
        override var token: TokenModel! {
            didSet {
                gasLimit = 21000
                changeGasLimitEnable = false
            }
        }
    }
}

extension TransactionService {
    class Erc20: TransactionService {
        override var token: TokenModel! {
            didSet {
                gasLimit = 21000
                changeGasLimitEnable = true
            }
        }
    }
}

extension TransactionService {
    class NervosErc20: TransactionService {
        override var token: TokenModel! {
            didSet {
                gasLimit = 100000
                do {
                    let result = try Utils.getQuotaPrice(appChain: NervosNetwork.getNervos()).dematerialize()
                    gasPrice = Double(result.words.first ?? 1)
                } catch {
                    gasPrice = 1.0
                }
                changeGasLimitEnable = false
                changeGasPriceEnable = false
            }
        }
    }
}

//0xA87498f97E14df93498f3F5818A421FaA5C21cFd
