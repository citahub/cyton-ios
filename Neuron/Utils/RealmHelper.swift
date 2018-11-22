//
//  RealmHelpers.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/8.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    var realm: Realm {
        let realm = try! Realm()
        realm.autorefresh = true
        return realm
    }
    private static var schemaVersion: UInt64 = 5

    static func configureRealm() {
        var config = Realm.Configuration()
        config.schemaVersion = schemaVersion
        config.migrationBlock = migrationBlock

        Realm.Configuration.defaultConfiguration = config
    }
}

private extension RealmHelper {
    static var migrationBlock: MigrationBlock {
        return { migration, oldSchemaVersion in
            if oldSchemaVersion < schemaVersion {
            }
        }
    }
}
