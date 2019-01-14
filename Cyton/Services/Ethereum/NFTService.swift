//
//  NFTService.swift
//  Cyton
//
//  Created by XiaoLu on 2018/9/11.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

struct NFTService {
    func getErc721Data(with address: String) throws -> NFTModel {
        let url = ServerApi.openseaURL + address
        return try Promise<NFTModel>.init { (resolver) in
            Alamofire.request(url, method: .get).responseJSON { (response) in
                if response.error == nil {
                    let nftModel = try! JSONDecoder().decode(NFTModel.self, from: response.data!)
                    resolver.fulfill(nftModel)
                } else {
                    resolver.reject(response.error!)
                }
            }
        }.wait()
    }
}

struct NFTModel: Decodable {
    var assets: [AssetsModel]?
}

struct AssetsModel: Decodable {
    var token_id: String
    var image_url: String?
    var image_preview_url: String?
    var image_thumbnail_url: String?
    var image_original_url: String?
    var background_color: String?
    var name: String?
    var description: String?
    var external_link: String?
    var asset_contract: AssetContract
    var traits: [TraitsModel?]
}

struct AssetContract: Decodable {
    var address: String
    var name: String?
    var symbol: String?
    var description: String?
}

struct TraitsModel: Decodable {
    var trait_type: String
    var value: AnyValue
    var trait_count: Int
}

struct AnyValue: Decodable {
    var int: Int?
    var string: String?

    init(_ int: Int) {
        self.int = int
    }

    init(_ string: String) {
        self.string = string
    }

    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self.int = int
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self.string = string
            return
        }
    }
}
