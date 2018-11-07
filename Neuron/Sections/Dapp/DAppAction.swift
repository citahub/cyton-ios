//
//  DAppAction.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import AppChain

struct DAppAction {
    enum Error: Swift.Error {
        case manifestRequestFailed
        case emptyChainHosts
        case emptyTX
    }

    func dealWithManifestJson(with link: String) {
        Alamofire.request(link, method: .get).responseJSON { (response) in
            do {
                guard let responseData = response.data else { throw Error.manifestRequestFailed }
                let manifest = try? JSONDecoder().decode(ManifestModel.self, from: responseData)
                guard let model = manifest else {
                    return
                }
                try? self.getMetaDataForDAppChain(with: model)
            } catch {

            }
        }
    }

    func getMetaDataForDAppChain(with manifestModel: ManifestModel) throws {
        guard let chainHosts = manifestModel.chainSet?.values.first else {
            throw Error.emptyChainHosts
        }
        let appChain = NervosNetwork.getNervos(with: chainHosts)
        DispatchQueue.global().async {
            let result = appChain.rpc.getMetaData()
            DispatchQueue.main.async {
                switch result {
                case .success(let metaData):
                    let tokenModel = TokenModel()
                    tokenModel.address = ""
                    tokenModel.chainId = metaData.chainId.description
                    tokenModel.chainName = metaData.chainName
                    tokenModel.iconUrl = metaData.tokenAvatar
                    tokenModel.isNativeToken = true
                    tokenModel.name = metaData.tokenName
                    tokenModel.symbol = metaData.tokenSymbol
                    tokenModel.decimals = NaticeDecimals.nativeTokenDecimals
                    tokenModel.chainidName = metaData.chainName + metaData.chainId.description
                    tokenModel.chainHosts = chainHosts
                    self.saveToken(model: tokenModel)
                case .failure:
                    break
                }
            }
        }
    }

    private func saveToken(model: TokenModel) {
        let appModel = WalletRealmTool.getCurrentAppModel()
        let alreadyContain = appModel.nativeTokenList.contains(where: {$0.chainidName == model.chainidName})
        try? WalletRealmTool.realm.write {
            WalletRealmTool.realm.add(model, update: true)
            if !alreadyContain {
                appModel.nativeTokenList.append(model)
            }
        }
    }
}

struct ManifestModel: Decodable {
    var shortName: String?
    var name: String?
    var startUrl: String?
    var display: String?
    var themeColor: String?
    var backgroundColor: String?
    var blockViewer: String?
    var chainSet: [String: String]?
    var entry: String?

    enum CodingKeys: String, CodingKey {
        case shortName = "short_name"
        case name
        case startUrl = "start_url"
        case display
        case themeColor = "theme_color"
        case backgroundColor = "background_color"
        case blockViewer
        case chainSet
        case entry
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        shortName = try? values.decode(String.self, forKey: .shortName)
        name = try? values.decode(String.self, forKey: .name)
        startUrl = try? values.decode(String.self, forKey: .startUrl)
        display = try? values.decode(String.self, forKey: .display)
        themeColor = try? values.decode(String.self, forKey: .themeColor)
        backgroundColor = try? values.decode(String.self, forKey: .backgroundColor)
        blockViewer = try? values.decode(String.self, forKey: .blockViewer)
        chainSet = try? values.decode([String: String].self, forKey: .chainSet)
        entry = try? values.decode(String.self, forKey: .entry)
    }
}

struct TitleBarModel: Decodable {
    var right: RightBarModel?
}

struct RightBarModel: Decodable {
    var isShow: Bool?
    var action: String?
    var type: String?
}
