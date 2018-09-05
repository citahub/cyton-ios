//
//  APIMacro.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/9.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

let NERVOS_SERVER_URL = "http://47.97.171.140:4000"
let NERVOS_TRANSACTION_URL = NERVOS_SERVER_URL + "/api/transactions"

let ETHER_SCAN_API_KEY = "T9GV1IF4V7YDXQ8F53U1FK2KHCE2KUUD8Z"
let ETH_TRANSACTION_URL = "http://api.etherscan.io/api?apikey=" + ETHER_SCAN_API_KEY + "&module=account&action=txlist&sort=asc"

let CURRENCY_PRICE_URL = "https://api.coinmarketcap.com/v2/ticker/"
