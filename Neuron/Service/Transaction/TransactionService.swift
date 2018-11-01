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

class TransactionService {
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
    }

    func success() {
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
    var isEffectiveTransferInfo: Bool {
        if toAddress.count != 40 && toAddress.count != 42 {
            Toast.showToast(text: "您的地址错误，请重新输入")
            return false
        } else if toAddress != toAddress.lowercased() {
            let eip55String = TrustCore.EthereumAddress(string: toAddress)?.eip55String ?? ""
            if eip55String != toAddress {
                Toast.showToast(text: "您的地址错误，请重新输入")
                return false
            }
        } else if amount > tokenBalance - gasCost {
            let alert = UIAlertController(title: "您输入的金额超过您的余额，是否全部转出？", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (_) in

            }))
            alert.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (_) in

            }))
            return false
        }
        return true
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
