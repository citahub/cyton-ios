//
//  DAppAction.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire

struct DAppAction {
    static func dealWithManifestJson(with link: String) {
        Alamofire.request(link, method: .get).responseJSON { (response) in
            do {
                guard let responseData = response.data else { throw DAppActionError.manifestRequestFailed }
                let manifest = try? JSONDecoder().decode(ManifestModel.self, from: responseData)
            } catch {

            }
        }
    }

}

struct ManifestModel: Decodable {
    var shortName: String
    var name: String
    var icon: String
    var startUrl: String
    var display: String
    var themeColor: String
    var backgroundColor: String
    var blockViewer: String
    var chainSet: [String: String]
    var entry: String

    enum CodingKeys: String, CodingKey {
        case shortName = "short_name"
        case name
        case icon
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
        shortName = try values.decode(String.self, forKey: .shortName)
        name = try values.decode(String.self, forKey: .name)
        icon = try values.decode(String.self, forKey: .icon)
        startUrl = try values.decode(String.self, forKey: .startUrl)
        display = try values.decode(String.self, forKey: .display)
        themeColor = try values.decode(String.self, forKey: .themeColor)
        backgroundColor = try values.decode(String.self, forKey: .backgroundColor)
        blockViewer = try values.decode(String.self, forKey: .blockViewer)
        chainSet = try values.decode([String: String].self, forKey: .chainSet)
        entry = try values.decode(String.self, forKey: .entry)
    }
}

enum DAppActionError: Error {
    case manifestRequestFailed
}
