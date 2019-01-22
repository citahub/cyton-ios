//
//  DAppAction.swift
//  Cyton
//
//  Created by XiaoLu on 2018/10/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire
import CITA
import RealmSwift

struct DAppAction {
    enum Error: Swift.Error {
        case manifestRequestFailed
        case emptyChainHosts
        case emptyTX
    }

    func collectDApp(manifestLink: String?, dappLink: String, title: String, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let convertedDate = dateFormatter.string(from: Date())
        if manifestLink == nil {
            let realm = try! Realm()
            let dappModel = DAppModel()
            dappModel.name = title
            dappModel.entry = dappLink
            dappModel.iconUrl = dappLink + "/favicon.ico"
            dappModel.date = convertedDate
            try! realm.write {
                realm.add(dappModel, update: true)
                completion(true)
            }
        } else {
            Alamofire.request(manifestLink!, method: .get).responseJSON { (response) in
                do {
                    guard let responseData = response.data else { throw Error.manifestRequestFailed }
                    let manifest = try? JSONDecoder().decode(Manifest.self, from: responseData)
                    let realm = try! Realm()
                    let dappModel = DAppModel()
                    if let model = manifest {
                        dappModel.name = model.name
                        dappModel.entry = dappLink
                        dappModel.iconUrl = model.icon
                        dappModel.date = convertedDate
                    } else {
                        dappModel.name = title
                        dappModel.entry = dappLink
                        dappModel.iconUrl = dappLink + "/favicon.ico"
                        dappModel.date = convertedDate
                    }
                    try? realm.write {
                        realm.add(dappModel, update: true)
                        completion(true)
                    }
                } catch {
                    completion(false)
                }
            }
        }
    }

    func dealWithManifestJson(with link: String) {
        Alamofire.request(link, method: .get).responseJSON { (response) in
            do {
                guard let responseData = response.data else { throw Error.manifestRequestFailed }
                let manifest = try? JSONDecoder().decode(Manifest.self, from: responseData)
                guard let model = manifest else {
                    return
                }
                try? self.getMetaDataForDAppChain(with: model)
            } catch {

            }
        }
    }

    func getMetaDataForDAppChain(with manifest: Manifest) throws {
        guard let chainNode = manifest.chainSet?.values.first, let url = URL(string: chainNode) else {
            throw Error.emptyChainHosts
        }
        let cita = CITANetwork(url: url).cita
        DispatchQueue.global().async {
            do {
                let metaData = try cita.rpc.getMetaData()
                DispatchQueue.main.async {
                    let chainModel = ChainModel()
                    chainModel.chainId = metaData.chainId
                    chainModel.chainName = metaData.chainName
                    chainModel.httpProvider = chainNode
                    if let chainIndentifier = ChainModel.identifier(for: chainModel) {
                        chainModel.identifier = chainIndentifier
                    }

                    let tokenModel = TokenModel()
                    tokenModel.address = ""
                    tokenModel.iconUrl = metaData.tokenAvatar
                    tokenModel.isNativeToken = true
                    tokenModel.name = metaData.tokenName
                    tokenModel.symbol = metaData.tokenSymbol
                    tokenModel.decimals = NativeDecimals.nativeTokenDecimals
                    tokenModel.chainIdentifier = chainModel.identifier
                    self.saveToken(tokenModel: tokenModel, chainModel: chainModel)
                }
            } catch {
            }
        }
    }

    private func saveToken(tokenModel: TokenModel, chainModel: ChainModel) {
        let wallet = AppModel.current.currentWallet!
        let selectExist = wallet.selectedTokenList.contains(where: { $0 == tokenModel })
        let tokenExist = wallet.tokenModelList.contains(where: { $0 == tokenModel })
        let chainExist = wallet.chainModelList.contains(where: { $0 == chainModel })
        if let id = TokenModel.identifier(for: tokenModel) {
            tokenModel.identifier = id
        }
        let realm = try! Realm()
        try? realm.write {
            realm.add(tokenModel, update: true)
            realm.add(chainModel, update: true)
            if !selectExist {
                wallet.selectedTokenList.append(tokenModel)
            }
            if !tokenExist {
                wallet.tokenModelList.append(tokenModel)
            }
            if !chainExist {
                wallet.chainModelList.append(chainModel)
            }
        }
    }
}

struct Manifest: Decodable {
    var shortName: String?
    var name: String?
    var startUrl: String?
    var display: String?
    var themeColor: String?
    var backgroundColor: String?
    var blockViewer: String?
    var chainSet: [String: String]?
    var entry: String?
    var icon: String?

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
