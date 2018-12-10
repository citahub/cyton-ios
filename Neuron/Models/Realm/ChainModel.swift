//
//  ChainModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/5.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class ChainModel: Object {
    @objc dynamic var chainId = ""
    @objc dynamic var chainName = ""
    @objc dynamic var httpProvider = ""
    @objc dynamic var tokenIdentifier = ""
    @objc dynamic var identifier = UUID().uuidString

    override class func primaryKey() -> String? {
        return "identifier"
    }
}

extension ChainModel {
    static func identifier(for chainModel: ChainModel) -> String? {
        guard let walletModel = AppModel.current.currentWallet else {
            return nil
        }
        var chainList: [ChainModel] = []
        chainList += walletModel.chainModelList
        if let model = chainList.first(where: { $0 == chainModel }) {
            return model.identifier
        }
        return nil
    }
}

extension ChainModel {
    public static func == (lhs: ChainModel, rhs: ChainModel) -> Bool {
        return lhs.chainId == rhs.chainId && lhs.chainName == rhs.chainName && lhs.httpProvider == rhs.httpProvider
    }
}
