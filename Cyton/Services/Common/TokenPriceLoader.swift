//
//  TokenPriceLoader.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/29.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class TokenPriceLoader {
    private class Token: Decodable {
        var id: Int = 0
        var name: String = ""
        var symbol: String = ""
    }

    private struct TokenListResponse: Decodable {
        let data: [Token]
    }

    private struct TokenQuotes: Decodable {
        let id: Int
        let name: String
        let symbol: String
        let quotes: [String: Quotes]
    }

    private struct Quotes: Decodable {
        let price: Double
    }

    private struct TokenQuotesResponse: Decodable {
        let data: TokenQuotes
    }

    private static var tokens = [Token]()

    func getPrice(symbol: String, currency: String? = nil) -> Double? {
        guard EthereumNetwork().networkType == .mainnet else { return nil }
        guard let tokenId = getTokenId(symbol: symbol) else { return nil }
        let currency = currency ?? LocalCurrencyService.shared.getLocalCurrencySelect().short
        let url = URL(string: "https://api.coinmarketcap.com/v2/ticker/\(tokenId)/?convert=\(currency)")!
        return try? Promise<Double>.init { (resolver) in
            Alamofire.request(url).responseData { (response) in
                do {
                    guard let data = response.data else { throw response.error! }
                    let response = try JSONDecoder().decode(TokenQuotesResponse.self, from: data)
                    let ticker = response.data
                    let quotes = ticker.quotes[currency]
                    resolver.fulfill(quotes!.price)
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }

    private func getTokenId(symbol: String) -> Int? {
        return (try? getTokenList())?.first(where: { $0.symbol == symbol })?.id
    }

    private func getTokenList() throws -> [Token] {
        if TokenPriceLoader.tokens.count == 0 {
            TokenPriceLoader.tokens = (try? Promise<[Token]>.init { (resolver) in
                Alamofire.request(URL(string: "https://api.coinmarketcap.com/v2/listings/")!).response(queue: DispatchQueue.global()) { (response) in
                    do {
                        guard let data = response.data else { throw response.error! }
                        let response = try JSONDecoder().decode(TokenListResponse.self, from: data)
                        resolver.fulfill(response.data)
                    } catch {
                        resolver.reject(error)
                    }
                }
            }.wait()) ?? []
        }
        return TokenPriceLoader.tokens
    }
}
