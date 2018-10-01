//
//  CurrencyService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/5.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import Alamofire

struct CurrencyService {
    func getTokenList() -> [CurrencyToken] {
        let path = Bundle.main.path(forResource: "tokens-list", ofType: "json")!
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path))
        let tokenList = try! JSONDecoder().decode(CurrencyTokenList.self, from: jsonData!)
        return tokenList.data
    }

    func searchCurrencyId(for symbol: String) -> CurrencyToken? {
        let tokenList = getTokenList()
        let newTokenList = tokenList.filter {$0.symbol == symbol}
        if newTokenList.count != 0 {
            return newTokenList[0]
        } else {
            return nil
        }
    }

    func getCurrencyPrice(tokenid id: Int, currencyType: String, completion: @escaping (EthServiceResult<Double>) -> Void) {
        var convert = "/?convert=" + currencyType
        if currencyType.count == 0 {
            convert = ""
        }
        let path = ServerApi.currencyPriceURL + "\(id)" + convert
        Alamofire.request(path, method: .get).responseJSON { (response) in
            if response.error == nil {
                let currencyData = try! JSONDecoder().decode(CurrencyData.self, from: response.data!)
                let currencyPrice = currencyData.data.quotes[currencyType]!
                completion(EthServiceResult.success(currencyPrice.price))
            } else {
                completion(EthServiceResult.error(response.error!))
            }
        }
    }
}

struct CurrencyTokenList: Codable {
    var data: [CurrencyToken]
}

struct CurrencyToken: Codable {
    var id: Int
    var name: String
    var symbol: String
    var website_slug: String
}

struct CurrencyData: Codable {
    var data: CurrencyQuotes
}

struct CurrencyQuotes: Codable {
    var quotes: [String: CurrencyType]
}

struct CurrencyType: Codable {
    var price: Double
}
