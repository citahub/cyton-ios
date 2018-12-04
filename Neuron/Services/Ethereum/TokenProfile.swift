//
//  TokenProfile.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/24.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import Web3swift
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
        let overview = TokenProfile.Overview(zh: "Ethereum是一个运行智能合约的去中心化平台，应用将完全按照程序运作，不存在任何欺诈，审查与第三方干预的可能。")
        let detailUrl = URL(string: "https://ntp.staging.cryptape.com?coin=ethereum")
        var profile = TokenProfile(symbol: self.symbol, address: address, overview: overview, imageUrl: nil, image: UIImage(named: "eth_logo"), possess: nil, detailUrl: detailUrl, price: nil, priceText: nil)

        let currencyType = LocalCurrencyService.shared.getLocalCurrencySelect().short
        let symbol = self.symbol
        DispatchQueue.global().async {
            let price = TokenPriceLoader().getPrice(symbol: symbol, currency: currencyType)
            DispatchQueue.main.async {
                if let price = price {
                    let amount = self.tokenBalance * price
                    let possess = String(format: "%@ %.4f", LocalCurrencyService.shared.getLocalCurrencySelect().symbol, amount)
                    profile.possess = possess
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
                let balance = self.tokenBalance
                let amount = balance * price
                let possess = String(format: "%@ %.4f", currency.symbol, amount)
                profile.possess = possess
                profile.price = price
                profile.priceText = String(format: "%@ %.4f", LocalCurrencyService.shared.getLocalCurrencySelect().symbol, price)
                complection(profile)
            } else {
                complection(profile)
            }
        }
    }
}
