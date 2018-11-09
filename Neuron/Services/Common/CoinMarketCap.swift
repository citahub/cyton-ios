//
//  CoinMarketCap.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class CoinMarketCapToken: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var website_slug: String = ""

    @objc override class func primaryKey() -> String? {
        return "symbol"
    }

    struct Response: Decodable {
        let data: [CoinMarketCapToken]
    }
}

struct CoinMarketCapTicker: Decodable {
    let id: Int
    let name: String
    let symbol: String
    let website_slug: String
    let quotes: [String: Quotes]

    struct Quotes: Decodable {
        let price: Double
        let volume_24h: Double
        let market_cap: Double
        let percent_change_1h: Double
        let percent_change_24h: Double
        let percent_change_7d: Double
    }
    struct Response: Decodable {
        let data: CoinMarketCapTicker
    }
}

class CoinMarketCap {
    enum Error: Swift.Error {
        case fail
    }
    static let shared = CoinMarketCap()
    private let realm: Realm

    private init() {
        let document = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
        let fileURL = document.appendingPathComponent("coinmarketcap")
        realm = try! Realm(fileURL: fileURL)
    }

    func tokenQuotes(symbol: String, currency: String = "CNY", complection: @escaping (CoinMarketCapTicker.Quotes?, Error?) -> Void) {
        getTokenId(for: symbol) { (tokenId) in
            guard let tokenId = tokenId else { complection(nil, Error.fail); return }
            let url = URL(string: "https://api.coinmarketcap.com/v2/ticker/\(tokenId)/?convert=\(currency)")!
            Alamofire.request(url).responseData { (response) in
                guard let data = response.data else { complection(nil, Error.fail); return }
                let response = try? JSONDecoder().decode(CoinMarketCapTicker.Response.self, from: data)
                guard let ticker = response?.data else { complection(nil, Error.fail); return }
                guard let quotes = ticker.quotes[currency] else { complection(nil, Error.fail); return }
                complection(quotes, nil)
            }
        }
    }

    private func getTokenId(for symbol: String, complection: @escaping (Int?) -> Void) {
        if realm.objects(CoinMarketCapToken.self).count == 0 {
            requestTokenList {
                complection(self.realm.object(ofType: CoinMarketCapToken.self, forPrimaryKey: symbol)?.id)
            }
        } else {
            complection(realm.object(ofType: CoinMarketCapToken.self, forPrimaryKey: symbol)?.id)
        }
    }

    private func requestTokenList(complection: @escaping () -> Void) {
        Alamofire.request(URL(string: "https://api.coinmarketcap.com/v2/listings/")!).response(queue: DispatchQueue.global()) { (response) in
            DispatchQueue.main.async {
                guard let data = response.data else { complection(); return }
                let response = try? JSONDecoder().decode(CoinMarketCapToken.Response.self, from: data)
                guard let tokens = response?.data else { complection(); return }
                try? self.realm.write {
                    self.realm.add(tokens, update: true)
                }
                complection()
            }
        }
    }
}
