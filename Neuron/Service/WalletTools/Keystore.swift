//
//  Keystore.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/16.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

import Result
import TrustKeystore

protocol Keystore {

    var keysDirectory: URL { get }

    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void)

}

