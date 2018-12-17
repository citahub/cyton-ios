//
//  WalletModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/6.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

enum WalleIconType: String {
    case dog = "icon_wallet_dog"
    case fish = "icon_wallet_fish"
    case owl = "icon_wallet_owl"
    case parrot = "icon_wallet_parrot"
    case rat = "icon_wallet_rat"
    case squirrel = "icon_wallet_squirrel"
    case fox = "icon_wallet_fox"
    case tiger = "icon_wallet_tiger"

    var image: UIImage {
        return UIImage(named: rawValue)!
    }

    static var allType: [WalleIconType] {
        return [.dog, .fish, .owl, .parrot, .rat, .squirrel, .fox, .tiger]
    }
}

class WalletModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var address = ""
    @objc dynamic private var iconName: String!
    var selectedTokenList = List<TokenModel>()
    var tokenModelList = List<TokenModel>()
    var chainModelList = List<ChainModel>()

    var wallet: Wallet? {
        return WalletManager.default.wallet(for: address)
    }

    override static func primaryKey() -> String? {
        return "address"
    }

    var icon: WalleIconType {
        get {
            if let iconName = iconName {
                return WalleIconType(rawValue: iconName)!
            }
            let iconList = WalleIconType.allType
            var useCount = [Int].init(repeating: 0, count: WalleIconType.allType.count)
            let realm = try! Realm()
            realm.objects(WalletModel.self).forEach { (wallet) in
                guard let idx = iconList.firstIndex(where: { $0.rawValue == wallet.iconName }) else { return }
                useCount[idx] += 1
            }
            var minimumUsedCount = Int.max
            var minimumUsedList = [WalleIconType]()
            for (idx, count) in useCount.enumerated() {
                if count < minimumUsedCount {
                    minimumUsedCount = count
                    minimumUsedList.removeAll()
                }
                if count == minimumUsedCount {
                    minimumUsedList.append(iconList[idx])
                }
            }
            let randomIdx = arc4random_uniform(UInt32(minimumUsedList.count))
            try! (self.realm ?? realm).write {
                self.icon = minimumUsedList[Int(randomIdx)]
            }
            return self.icon
        }
        set {
            iconName = newValue.rawValue
        }
    }
}
