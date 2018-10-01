//
//  TransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Alamofire
import web3swift
import BigInt

class TransactionService {
    func didGetETHTransaction(walletAddress: String, completion: @escaping (EthServiceResult<[TransactionModel]>) -> Void) {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet
        let parameters: Dictionary = ["address": walletAddress]
        Alamofire.request(ServerApi.etherScanURL, method: .get, parameters: parameters).responseJSON { [weak self](response) in
            do {
                guard let responseData = response.data else { throw TransactionErrors.requestfailed }
                let ethTransaction = try? JSONDecoder().decode(TransactionResponse.self, from: responseData)
                guard let transactions = ethTransaction?.result.transactions else { throw TransactionErrors.requestfailed }
                var resultArr: [TransactionModel] = []
                guard let self = self else { throw TransactionErrors.requestfailed }
                for transacationModel in transactions {
                    transacationModel.formatTime = self.formatTimeStamp(timeStamp: transacationModel.timeStamp)
                    transacationModel.chainName = "Ethereum Mainnet"
                    transacationModel.gasPrice = self.formatGasToGwei(gas: transacationModel.gasPrice)
                    transacationModel.transactionType = "ETH"
                    transacationModel.symbol = "ETH"
                    if walletModel?.address.lowercased() == transacationModel.to {
                        transacationModel.value = "+" + self.formatScientValue(value: transacationModel.value) + transacationModel.symbol
                    } else {
                        transacationModel.value = "-" + self.formatScientValue(value: transacationModel.value) + transacationModel.symbol
                    }
                    transacationModel.totleGas = self.getTotleGas(gasUsed: transacationModel.gasUsed, gasPirce: transacationModel.gasPrice)

                    resultArr.append(transacationModel)
                }
                completion(EthServiceResult.success(resultArr))
            } catch {
                completion(EthServiceResult.error(error))
            }
        }
    }

    func didGetNervosTransaction(walletAddress: String, completion: @escaping (EthServiceResult<[TransactionModel]>) -> Void) {
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet
        let nativeTokenArray = WalletRealmTool.getCurrentAppModel().nativeTokenList
        let urlString = ServerApi.nervosTransactionURL + walletAddress.lowercased()
        Alamofire.request(urlString, method: .get, parameters: nil).responseJSON { [weak self](response) in
            do {
                guard let responseData = response.data else { throw TransactionErrors.requestfailed }
                let nervosTransaction = try? JSONDecoder().decode(TransactionResponse.self, from: responseData)
                guard let transactions = nervosTransaction?.result.transactions else { throw TransactionErrors.requestfailed }
                var resultArr: [TransactionModel] = []
                guard let self = self else { throw TransactionErrors.requestfailed }
                for transacationModel in transactions {
                    transacationModel.formatTime = self.formatTimestamp(timeStap: Int(transacationModel.timeStamp) ?? 0)
                    transacationModel.gasPrice = ""
                    transacationModel.gas = ""
                    transacationModel.gasUsed = self.formatGasUsed(gasString: transacationModel.gasUsed)
                    transacationModel.blockNumber = self.changeValue(eStr: transacationModel.blockNumber)
                    transacationModel.gasPrice = ""
                    transacationModel.gas = ""
                    transacationModel.transactionType = "Nervos"
                    nativeTokenArray.forEach({ (tokenModel) in
                        if tokenModel.chainId == transacationModel.chainId {
                            transacationModel.symbol = tokenModel.symbol
                        }
                    })
                    if walletModel?.address.lowercased() == transacationModel.to {
                        transacationModel.value = "+" + self.formatScientValue(value: transacationModel.value) + transacationModel.symbol
                    } else {
                        transacationModel.value = "-" + self.formatScientValue(value: transacationModel.value) + transacationModel.symbol
                    }

                    resultArr.append(transacationModel)
                }
                completion(EthServiceResult.success(resultArr))
            } catch {
                completion(EthServiceResult.error(error))
            }
        }
    }

    // MARK: - Utils

    func changeValue(eStr: String) -> String {
        var fStr: String
        if eStr.hasPrefix("0x") {
            let start = eStr.index(eStr.startIndex, offsetBy: 2)
            let str1 = String(eStr[start...])
            fStr = str1.uppercased()
        } else {
            fStr = eStr.uppercased()
        }
        var sum = 0
        for i in fStr.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return String(sum)
    }

    func formatGasUsed(gasString: String) -> String {
        let formatValue = changeValue(eStr: gasString)
        let final = Double(formatValue)!/pow(10, 18)
        return String(final)
    }

    func formatScientValue(value: String) -> String {
        let biguInt = BigUInt(atof(value))
        let format = Web3.Utils.formatToEthereumUnits(biguInt, toUnits: .eth, decimals: 8, fallbackToScientific: false)!
        let finalValue = Double(format)!
        return finalValue.clean
    }

    func getTotleGas(gasUsed: String, gasPirce: String) -> String {
        if gasUsed.count != 0 && gasUsed.count != 0 {
            let gasUsedInt = Int(gasUsed)!
            let gasPriceInt = Int(gasPirce)!
            let gasT = BigUInt(gasUsedInt * gasPriceInt)
            let formatStr = Web3.Utils.formatToEthereumUnits(gasT, toUnits: .eth, decimals: 8, fallbackToScientific: false)
            let strFload = Float(formatStr!)
            let finalGasStr = String(strFload!)
            return finalGasStr
        } else {
            return ""
        }
    }

    func formatGasToGwei(gas: String) -> String {
        if gas.count != 0 {
            let vInt = Int(gas)!
            let bigInt = BigUInt(vInt)
            let formatStr = Web3.Utils.formatToEthereumUnits(bigInt, toUnits: .Gwei, decimals: 8, fallbackToScientific: false)!
            return formatStr
        } else {
            return gas
        }
    }

    func formatTimeStamp(timeStamp: String) -> String {
        let timeStampInt = Int(timeStamp)
        let timeInterval: TimeInterval = TimeInterval(timeStampInt!)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateformatter.string(from: date)
        return time
    }

    func formatTimestamp(timeStap: Int) -> String {
        let timeInterval: TimeInterval = TimeInterval(timeStap)
        let date = Date(timeIntervalSince1970: timeInterval/1000)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateformatter.string(from: date)
        return time
    }
}
