//
//  TransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import web3swift
import BigInt

protocol TransactionService {
    func didGetETHTransaction(walletAddress:String,completion:@escaping (EthServiceResult<[TransactionModel]>) -> Void)
    func didGetNervosTransaction(walletAddress:String,completion:@escaping (EthServiceResult<[TransactionModel]>) -> Void)
}

class TransactionServiceImp : TransactionService{

    func didGetETHTransaction(walletAddress: String, completion: @escaping (EthServiceResult<[TransactionModel]>) -> Void) {
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet

        var resultArr:[TransactionModel] = []
        let parameters:Dictionary = ["address":walletAddress]
        Alamofire.request(ETH_TRANSACTION_URL, method: .get, parameters: parameters).responseJSON(){ (response) in
            let jsonObj = try? JSON(data: response.data!)
            print(jsonObj!["status"])
//            if jsonObj!["status"] != "1"{
//                completion(EthServiceResult.Error(TransactionErrors.Requestfailed))
//            }else{
            if response.error == nil {
                for (_, subJSON) : (String, JSON) in jsonObj!["result"] {
                    let transacationModel = TransactionModel()
                    transacationModel.from = subJSON["from"].stringValue
                    transacationModel.to = subJSON["to"].stringValue
                    transacationModel.hashString = subJSON["hash"].stringValue
                    transacationModel.timeStamp = subJSON["timeStamp"].stringValue
                    transacationModel.formatTime = self.formatTimeStamp(timeStamp: subJSON["timeStamp"].stringValue)
                    transacationModel.chainName = "Ethereum Mainnet"
                    transacationModel.gasPrice = self.formatGasToGwei(gas: subJSON["gasPrice"].stringValue)
                    transacationModel.gas = subJSON["gas"].stringValue
                    transacationModel.gasUsed = subJSON["gasUsed"].stringValue
                    transacationModel.blockNumber = subJSON["blockNumber"].stringValue
                    transacationModel.transactionType = "ETH"
                    if walletModel?.address.lowercased() == subJSON["to"].stringValue {
                        transacationModel.value = "+" + self.formatValue(value: subJSON["value"].stringValue) + "ETH"
                    }else{
                        transacationModel.value = "-" + self.formatValue(value: subJSON["value"].stringValue) + "ETH"
                    }
                    transacationModel.totleGas = self.getTotleGas(gasUsed: subJSON["gasUsed"].stringValue, gasPirce: subJSON["gasPrice"].stringValue)
                    resultArr.append(transacationModel)
                }
                completion(EthServiceResult.Success(resultArr))
            }else{
                completion(EthServiceResult.Error(TransactionErrors.Requestfailed))
            }
//            }
        }
    }
    
    func didGetNervosTransaction(walletAddress: String, completion: @escaping (EthServiceResult<[TransactionModel]>) -> Void) {
        var resultArr:[TransactionModel] = []
        let parameters:Dictionary = ["account":walletAddress]
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet
        Alamofire.request(NERVOS_TRANSACTION_URL, method: .get, parameters: parameters).responseJSON(){ (response) in
            let jsonObj = try? JSON(data: response.data!)
            if jsonObj!["result"]["count"] != "0" {
                for (_, subJSON) : (String, JSON) in jsonObj!["result"]["transactions"] {
                    let transacationModel = TransactionModel()
//                    transacationModel.value = subJSON["value"].stringValue
                    transacationModel.from = subJSON["from"].stringValue
                    transacationModel.to = subJSON["to"].stringValue
                    transacationModel.hashString = subJSON["hash"].stringValue
                    transacationModel.timeStamp = String(subJSON["timestamp"].intValue)
                    transacationModel.formatTime = self.formatTimestamp(timeStap: subJSON["timestamp"].intValue)
                    transacationModel.chainName = "Nervos Mainnet"
                    transacationModel.gasPrice = ""
                    transacationModel.gas = ""
                    transacationModel.gasUsed = self.changeValue(eStr: subJSON["gasUsed"].stringValue)
                    transacationModel.blockNumber = self.changeValue(eStr: subJSON["blockNumber"].stringValue)
                    transacationModel.transactionType = "Nervos"
                    if walletModel?.address.lowercased() == subJSON["to"].stringValue {
                        transacationModel.value = "+" + self.formatScientValue(value: subJSON["value"].stringValue) + "NOS"
                    }else{
                        transacationModel.value = "-" + self.formatScientValue(value: subJSON["value"].stringValue) + "NOS"
                    }

                    resultArr.append(transacationModel)
                }
                completion(EthServiceResult.Success(resultArr))
            }else{
                completion(EthServiceResult.Error(TransactionErrors.Requestfailed))
            }
        }
    }
    
    func changeValue(eStr:String) -> String{
        var fStr:String
        if eStr.hasPrefix("0x") {
            let start = eStr.index(eStr.startIndex, offsetBy: 2);
            let str1 = String(eStr[start...])
            fStr = str1.uppercased()
        }else{
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
    
    func formatValue(value:String) -> String {
        
        if value.count != 0 {
            let vInt = Int(value)!
            let biguInt = BigUInt(vInt)
            let formatStr = Web3.Utils.formatToEthereumUnits(biguInt, toUnits: .eth, decimals: 6, fallbackToScientific: false)!
            let strFload = Float(formatStr)
            let finalStr = String(strFload!)
            return finalStr
        }else{
            return value
        }
    }
    
    func formatScientValue(value:String) -> String {
        let biguInt = BigUInt(atof("0x" + value))
        let formatStr = Web3.Utils.formatToEthereumUnits(biguInt, toUnits: .eth, decimals: 6, fallbackToScientific: false)!
        return formatStr
    }
    
    
    func getTotleGas(gasUsed:String,gasPirce:String) -> String {
        if gasUsed.count != 0 && gasUsed.count != 0 {
            let gasUsedInt = Int(gasUsed)!
            let gasPriceInt = Int(gasPirce)!
            let gasT = BigUInt(gasUsedInt * gasPriceInt)
            let formatStr = Web3.Utils.formatToEthereumUnits(gasT, toUnits: .eth, decimals: 6, fallbackToScientific: false)
            let strFload = Float(formatStr!)
            let finalGasStr = String(strFload!)
            return finalGasStr
        }else{
            return ""
        }
    }
    
    func formatGasToGwei(gas:String) -> String {
        if gas.count != 0 {
            let vInt = Int(gas)!
            let bigInt = BigUInt(vInt)
            let formatStr = Web3.Utils.formatToEthereumUnits(bigInt, toUnits: .Gwei, decimals: 6, fallbackToScientific: false)!
            return formatStr
        }else{
            return gas
        }
    }
    
    func formatTimeStamp(timeStamp:String) -> String {
        let timeStampInt = Int(timeStamp)
        let timeInterval:TimeInterval = TimeInterval(timeStampInt!)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateformatter.string(from: date)
        return time
    }
    
    func formatTimestamp(timeStap:Int) -> String {
        print(timeStap)
        let timeInterval:TimeInterval = TimeInterval(timeStap)
        let date = Date(timeIntervalSince1970: timeInterval/1000)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateformatter.string(from: date)
        return time
    }
    
}



