//
//  WalletModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

enum WalleIcon: String, CaseIterable {
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

class WalletModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var address = ""
    @objc dynamic var iconName: String!
    var selectedTokenList = List<TokenModel>()
    var tokenModelList = List<TokenModel>()
    var chainModelList = List<ChainModel>()

    var wallet: Wallet? {
        return WalletManager.default.wallet(for: address)
    }

    override static func primaryKey() -> String? {
        return "address"
    }

    var icon: WalleIcon {
        get {
            if let iconName = iconName {
                return WalleIcon(rawValue: iconName)!
            }
            try! (realm ?? Realm()).write {
                self.icon = WalleIcon.randomIcon()
            }
            return self.icon
        }
        set {
            iconName = newValue.rawValue
        }
    }
}

extension WalleIcon {
    static func randomIcon() -> WalleIcon {
        let iconList = WalleIcon.allCases
        var useCount = [Int].init(repeating: 0, count: WalleIcon.allCases.count)
        try! Realm().objects(WalletModel.self).forEach { (wallet) in
            guard let idx = iconList.firstIndex(where: { $0.rawValue == wallet.iconName }) else { return }
            useCount[idx] += 1
        }
        var minimumUsedCount = Int.max
        var minimumUsedList = [WalleIcon]()
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
