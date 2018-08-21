//
//  TransactionModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TransactionModel: NSObject {

    var value = ""
    var from = ""
    var to = ""
    var hashString = ""
    var timeStamp = ""
    var chainName = ""
    var gasUsed = ""
    var gas = ""
    var gasPrice = ""
    var blockNumber = ""

    var transactionType = "ETH" //default "ETH" include ERC20 transaction,  another one is "Nervos"
    var totleGas = ""
    var formatTime = ""
}
