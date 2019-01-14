//
//  RealmConfigurator.swift
//  Cyton
//
//  Created by XiaoLu on 2018/6/8.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift

class RealmConfigurator {
    private static var schemaVersion: UInt64 = 16

    static func configure() {
        var config = Realm.Configuration()
        config.schemaVersion = schemaVersion
        config.migrationBlock = migrationBlock

        Realm.Configuration.defaultConfiguration = config
    }
}

private extension RealmConfigurator {
    static var migrationBlock: MigrationBlock {
        return { migration, oldSchemaVersion in
            if oldSchemaVersion < schemaVersion {
            }
        }
    }
}
