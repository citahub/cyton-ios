//
//  TokenProfile.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import EthereumAddress

// TODO: Refactor
struct TokenProfile: Decodable {
    let symbol: String
    let address: String
    var overview: Overview
    var imageUrl: String?
    var image: UIImage?
    var possess: String?
    var detailUrl: URL?
    var price: Double?
    var priceText: String?

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
        case .ether:
            getEthereumProfile(complection: complection)
        case .erc20:
            getErc20Profile(complection: complection)
        case .appChain, .appChainErc20:
            complection(nil)
        }
    }

    private func getEthereumProfile(complection: @escaping (TokenProfile?) -> Void) {
        let overview = TokenProfile.Overview(zh: "TokenProfile.Ether.overview".localized())
        let detailUrl = URL(string: "https://ntp.staging.cryptape.com?coin=ethereum")
        var profile = TokenProfile(symbol: self.symbol,
                                   address: address,
                                   overview: overview,
                                   imageUrl: nil,
                                   image: UIImage(named: "eth_logo"),
                                   possess: nil,
                                   detailUrl: detailUrl,
                                   price: nil,
                                   priceText: nil)

        let currencyType = LocalCurrencyService.shared.getLocalCurrencySelect().short
        let symbol = self.symbol
        DispatchQueue.global().async {
            let price = TokenPriceLoader().getPrice(symbol: symbol, currency: currencyType)
            DispatchQueue.main.async {
                if let price = price {
                    let amountText = self.balance.toDecimalNumber(self.decimals).multiplying(by: NSDecimalNumber(value: price)).formatterToString(4)
                    profile.possess = LocalCurrencyService.shared.getLocalCurrencySelect().symbol + amountText
                    profile.price = price
                    profile.priceText = String(format: "%@ %.4f", LocalCurrencyService.shared.getLocalCurrencySelect().symbol, price)
                }
                complection(profile)
            }
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
        let currency = LocalCurrencyService.shared.getLocalCurrencySelect()
        let symbol = self.symbol
        DispatchQueue.global().async {
            price = TokenPriceLoader().getPrice(symbol: symbol, currency: currency.short)
            group.leave()
        }

        group.notify(queue: .main) {
            profile?.detailUrl = URL(string: "https://ntp.staging.cryptape.com?token=\(address)")
            if var profile = profile, let price = price {
                let amountText = self.balance.toDecimalNumber(self.decimals).multiplying(by: NSDecimalNumber(value: price)).formatterToString(4)
                profile.possess = LocalCurrencyService.shared.getLocalCurrencySelect().symbol + amountText
                profile.price = price
                profile.priceText = String(format: "%@ %.4f", LocalCurrencyService.shared.getLocalCurrencySelect().symbol, price)
                complection(profile)
            } else {
                complection(profile)
            }
        }
    }
}
