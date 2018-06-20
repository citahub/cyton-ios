//
//  ETHKeyStore.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/15.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import TrustKeystore
import Result

open class ETHKeyStore: Keystore {
    

    static let shared = ETHKeyStore()
    
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keyStore: KeyStore
    let keysDirectory: URL
    let userDefaults: UserDefaults
    
    public init(
        keysSubfolder: String = "/keystore",
        userDefaults: UserDefaults = UserDefaults.standard
        ) {
        self.keysDirectory = URL(fileURLWithPath: datadir + keysSubfolder)
        self.keyStore = try! KeyStore(keyDirectory: keysDirectory)
        self.userDefaults = userDefaults
    }
    
    
    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }
    
    func createAccout(password: String) -> Account {
        let account = try! keyStore.createAccount(password: password, type: .encryptedKey)
        return account
    }
    
}
