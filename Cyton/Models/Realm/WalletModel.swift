//
//  WalletModel.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class WalletModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var address = ""
    @objc dynamic var iconName: String!
    var selectedTokenList = List<TokenModel>()
    var tokenModelList = List<TokenModel>()
    var chainModelList = List<ChainModel>()
    var balanceList = List<TokenBalance>()

    var wallet: Wallet? {
        return WalletManager.default.wallet(for: address)
    }

    var icon: Icon {
        get {
            if let iconName = iconName {
                return Icon(rawValue: iconName)!
            }
            try! (realm ?? Realm()).write {
                self.icon = Icon.random()
            }
            return self.icon
        }
        set {
            iconName = newValue.rawValue
        }
    }

    override static func primaryKey() -> String? { return "address" }
}

class TokenBalance: Object {
    @objc dynamic var identifier: String! // token identifier
    @objc dynamic var value: String!      // token balance
}

extension WalletModel {
    enum Icon: String, CaseIterable {
        case dog
        case fish
        case owl
        case parrot
        case rat
        case squirrel
        case fox
        case tiger

        var image: UIImage {
            return UIImage(named: "wallet_icon_\(rawValue)")!
        }
    }
}

extension WalletModel.Icon {
    static func random() -> WalletModel.Icon {
        let iconList = WalletModel.Icon.allCases
        var useCount = [Int].init(repeating: 0, count: iconList.count)
        try! Realm().objects(WalletModel.self).forEach { (wallet) in
            guard let idx = iconList.firstIndex(where: { $0.rawValue == wallet.iconName }) else { return }
            useCount[idx] += 1
        }
        var minimumUsedCount = Int.max
        var minimumUsedList = [WalletModel.Icon]()
        for (idx, count) in useCount.enumerated() {
            if count < minimumUsedCount {
                minimumUsedCount = count
                minimumUsedList.removeAll()
            }
            if count == minimumUsedCount {
                minimumUsedList.append(iconList[idx])
            }
        }
        let randomIdx = Int.random(in: 0..<minimumUsedList.count)
        return minimumUsedList[randomIdx]
    }
}
