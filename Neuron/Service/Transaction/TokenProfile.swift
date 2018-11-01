//
//  TokenProfile.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import web3swift

struct TokenProfile: Decodable {
    let symbol: String
    let address: String
    var overview: Overview
    var imageUrl: String?
    var image: UIImage?
    var possess: String?
    var detailUrl: URL?
    var price: Double?

    struct Overview: Decodable {
        var zh: String
    }

    enum CodingKeys: String, CodingKey {
        case symbol
        case address
        case overview
        case imageUrl
    }
}

extension TokenModel {
    func getProfile(complection: @escaping (TokenProfile?) -> Void) {
        switch type {
        case .erc20:
            getErc20Profile(complection: complection)
        case .nervos, .nervosErc20:
            complection(nil)
        case .ethereum:
            getEthereumProfile(complection: complection)
        }
    }

    private func getEthereumProfile(complection: @escaping (TokenProfile?) -> Void) {
        let overview = TokenProfile.Overview(zh: "Ethereum是一个运行智能合约的去中心化平台，应用将完全按照程序运作，不存在任何欺诈，审查与第三方干预的可能。")
        let detailUrl = URL(string: "https://ntp.staging.cryptape.com?coin=ethereum")
        var profile = TokenProfile(symbol: symbol, address: address, overview: overview, imageUrl: nil, image: UIImage(named: "eth_logo"), possess: nil, detailUrl: detailUrl, price: nil)

        let currency = CurrencyService()
        let currencyToken = currency.searchCurrencyId(for: symbol)
        guard let tokenId = currencyToken?.id else {
            complection(profile)
            return
        }
        let currencyType = LocalCurrencyService().getLocalCurrencySelect().short
        currency.getCurrencyPrice(tokenid: tokenId, currencyType: currencyType) { (result) in
            switch result {
            case .success(let value):
                profile.price = value
            default:
                break
            }
            complection(profile)
        }
    }

    private func getErc20Profile(complection: @escaping (TokenProfile?) -> Void) {
        let group = DispatchGroup()
        var profile: TokenProfile?
        var price: Double?

        group.enter()
        let address = EthereumAddress.toChecksumAddress(self.address) ?? self.address
        let urlString = "https://raw.githubusercontent.com/consenlabs/token-profile/master/erc20/\(address).json"
        Alamofire.request(URL(string: urlString)!, method: .get, parameters: nil).responseData { (response) in
            defer { group.leave() }
            guard let data = response.data else {
                return
            }
            profile = try? JSONDecoder().decode(TokenProfile.self, from: data)
            profile?.imageUrl = "https://raw.githubusercontent.com/consenlabs/token-profile/master/images/\(address).png"
        }

        group.enter()
        let currency = LocalCurrencyService().getLocalCurrencySelect()
        CoinMarketCap.shared.tokenQuotes(symbol: symbol, currency: currency.short) { (quotes, _) in
            defer { group.leave() }
            price = quotes?.price
        }

        group.notify(queue: .main) {
            profile?.detailUrl = URL(string: "https://ntp.staging.cryptape.com?token=\(address)")
            if var profile = profile, let price = price {
                let balance = Double(self.tokenBalance) ?? 0.0
                let amount = balance * price
                let possess = String(format: "%@ %.2f", currency.symbol, amount)
                profile.possess = possess
                profile.price = price
                complection(profile)
            } else {
                complection(profile)
            }
        }
    }
}
