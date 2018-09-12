//
//  APIMacro.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

struct ServerApi {
    static let nervorURL = "http://47.97.171.140:4000"
    static let nervosTransactionURL = nervorURL + "/api/transactions"
    static let etherScanKey = "T9GV1IF4V7YDXQ8F53U1FK2KHCE2KUUD8Z"
    static let etherScanURL = "http://api.etherscan.io/api?apikey=" + etherScanKey + "&module=account&action=txlist&sort=asc"
    static let currencyPriceURL = "https://api.coinmarketcap.com/v2/ticker/"
    static let openseaURL = "https://api.opensea.io/api/v1/assets/?format=json&owner="
}
