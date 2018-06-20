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
    
    //使用默认的文件名和路径
    static var sharedInstance = try! Realm()
    
    /// 版本号
    private static var schemaVersion:UInt64 = 0
    
    
    //--MARK: 初始化 Realm
    /// 初始化进过加密的 Realm， 加密过的 Realm 只会带来很少的额外资源占用（通常最多只会比平常慢10%）
    static func initEncryptionRealm() {
        print(String(data: getKey() as Data, encoding: String.Encoding.utf8)?.replacingOccurrences(of: " ", with: "") ?? "")
        // 打开加密文件
        // Open the encrypted Realm file
        var config = Realm.Configuration()
        config.schemaVersion = schemaVersion
        config.encryptionKey = getKey() as Data
        //使用默认目录，但是使用用户名来代替默认的文件名
//        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        //获取Realm文件的父级目录
        let folderPath = config.fileURL?.deletingLastPathComponent().path
        /**
         *  设置可以在后台应用刷新中使用 Realm
         *  注意：以下的操作其实是关闭了 Realm 文件的 NSFileProtection 属性加密功能，将文件保护属性降级为一个不太严格的、允许即使在设备锁定时都可以访问文件的属性
         */
        // 禁用此目录的文件保护
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],ofItemAtPath: folderPath!)
        print(config)
        // 将这个配置应用到默认的 Realm 数据库当中
        Realm.Configuration.defaultConfiguration = config
    }
    

    
    //--- MARK: 操作 Realm
    /// 做写入操作
    static func doWriteHandler(clouse: ()->()) { // 这里用到了 Trailing 闭包
        try! sharedInstance.write {
            clouse()
        }
    }
    
    /// 添加一条数据
    static func addCanUpdate<T: Object>(object: T) {
        try! sharedInstance.write {
            sharedInstance.add(object, update: true)
        }
    }
    static func add<T: Object>(object: T) {
        try! sharedInstance.write {
            sharedInstance.add(object)
        }
    }
    /// 后台单独进程写入一组数据
    static func addListDataAsync<T: Object>(objects: [T]) {
        let queue = DispatchQueue.global()
//        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        // Import many items in a background thread
        queue.async() {
            // 为什么添加下面的关键字，参见 Realm 文件删除的的注释
            autoreleasepool {
                // 在这个线程中获取 Realm 和表实例
                let realm = try! Realm()
                // 批量写入操作
                realm.beginWrite()
                // add 方法支持 update ，item 的对象必须有主键
                for item in objects {
                    realm.add(item, update: true)
                }
                // 提交写入事务以确保数据在其他线程可用
                try! realm.commitWrite()
            }
        }
    }
    
    static func addListData<T: Object>(objects: [T]) {
        autoreleasepool {
            // 在这个线程中获取 Realm 和表实例
            let realm = try! Realm()
            // 批量写入操作
            realm.beginWrite()
            // add 方法支持 update ，item 的对象必须有主键
            for item in objects {
                realm.add(item, update: true)
            }
            // 提交写入事务以确保数据在其他线程可用
            try! realm.commitWrite()
        }
    }
    
    /// 删除某个数据
    static func delete<T: Object>(object: T) {
        try! sharedInstance.write {
            sharedInstance.delete(object)
        }
    }
    
    /// 批量删除数据
    static func delete<T: Object>(objects: [T]) {
        try! sharedInstance.write {
            sharedInstance.delete(objects)
        }
    }
    /// 批量删除数据
    static func delete<T: Object>(objects: List<T>) {
        try! sharedInstance.write {
            sharedInstance.delete(objects)
        }
    }
    /// 批量删除数据
    static func delete<T: Object>(objects: Results<T>) {
        try! sharedInstance.write {
            sharedInstance.delete(objects)
        }
    }
    
    /// 批量删除数据
    static func delete<T: Object>(objects: LinkingObjects<T>) {
        try! sharedInstance.write {
            sharedInstance.delete(objects)
        }
    }
    
    
    /// 删除所有数据。注意，Realm 文件的大小不会被改变，因为它会保留空间以供日后快速存储数据
    static func deleteAll() {
        try! sharedInstance.write {
            sharedInstance.deleteAll()
        }
    }
    
    /// 根据条件查询数据
    static func selectByNSPredicate<T: Object>(_: T.Type , predicate: NSPredicate) -> Results<T>{
        return sharedInstance.objects(T.self).filter(predicate)
    }
    
    //--- MARK: 删除 Realm
    /*
     参考官方文档，所有 fileURL 指向想要删除的 Realm 文件的 Realm 实例，都必须要在删除操作执行前被释放掉。
     故在操作 Realm实例的时候需要加上 autoleasepool 。如下:
     autoreleasepool {
     //所有 Realm 的使用操作
     }
     */
    /// Realm 文件删除操作
    static func deleteRealmFile() {
        var realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendPathExtension("lock"),
            realmURL.appendPathExtension("log_a"),
            realmURL.appendPathExtension("log_b"),
            realmURL.appendPathExtension("note")
            ] as [Any]
        let manager = FileManager.default
        for URL in realmURLs {
            do {
                try manager.removeItem(at: URL as! URL)
            } catch {
                // 处理错误
            }
        }
    }
}
