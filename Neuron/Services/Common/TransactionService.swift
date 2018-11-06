//
//  TransactionService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import BigInt
import Web3swift
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
    var password: String = ""
    var isUseQRCode = false

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
