//
//  CurrencyService.swift
//  Cyton
//
//  Created by XiaoLu on 2018/9/6.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation

final class LocalCurrencyService {
    private let localCurrencyKey = "localCurrency"
    static let shared = LocalCurrencyService()

    private init() {
        let selected = UserDefaults.standard.string(forKey: localCurrencyKey)
        if selected == nil {
            UserDefaults.standard.set("CNY", forKey: localCurrencyKey)
        }
    }

    func saveLocalCurrency(_ short: String) {
        UserDefaults.standard.set(short, forKey: localCurrencyKey)
    }

    func getLocalCurrencySelect() -> LocalCurrency {
        let currencyList = getLocalCurrencyList()
        let short = UserDefaults.standard.string(forKey: localCurrencyKey)
        let currencySelected = currencyList.filter {$0.short == short}
        return currencySelected[0]
    }

    func getLocalCurrencyList() -> [LocalCurrency] {
        let path = Bundle.main.path(forResource: "currency", ofType: "plist")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let currencyList = try! PropertyListDecoder().decode([LocalCurrency].self, from: data)
        return currencyList
    }
}

struct LocalCurrency: Codable {
    var name: String
    var short: String
    var symbol: String
    var identifier: String
}
