//
//  DAppModel.swift
//  Cyton
//
//  Created by XiaoLu on 2018/11/22.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class DAppModel: Object {
    @objc dynamic var name: String? = ""
    @objc dynamic var iconUrl: String? = ""
    @objc dynamic var entry: String = ""
    @objc dynamic var date: String? = ""

    override class func primaryKey() -> String? {
        return "entry"
    }
}
