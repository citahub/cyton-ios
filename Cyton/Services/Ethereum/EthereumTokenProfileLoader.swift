//
//  EthereumTokenProfileLoader.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/20.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import PromiseKit
import web3swift
import Alamofire

typealias TokenOverview = String
typealias TokenIconURL = String

class EthereumTokenProfileLoader {
    private struct TokenProfile: Decodable {
        var overview: Overview?
    }
    private struct Overview: Decodable {
        var zh: String?
        var en: String?
    }

    func loadTokenProfile(address: String) throws -> (TokenIconURL, TokenOverview) {
        return try Promise<(TokenIconURL, TokenOverview)>.init { (resolver) in
            guard address.count > 0, let address = EthereumAddress.toChecksumAddress(address) else {
                resolver.fulfill(("", "TokenProfile.Ether.overview".localized()))
                return
            }
            Alamofire.request("https://raw.githubusercontent.com/consenlabs/token-profile/master/erc20/\(address).json").responseData { (response) in
                do {
                    guard let data = response.data else { throw response.error! }
                    let profile = try JSONDecoder().decode(TokenProfile.self, from: data)
                    if Locale.current.identifier.contains("zh") {
                        resolver.fulfill(("https://raw.githubusercontent.com/consenlabs/token-profile/master/images/\(address).png", profile.overview?.zh ?? ""))
                    } else {
                        resolver.fulfill(("https://raw.githubusercontent.com/consenlabs/token-profile/master/images/\(address).png", profile.overview?.en ?? ""))
                    }
                } catch {
                    resolver.reject(error)
                }
            }
        }.wait()
    }
}
