//
//  ImportResult.swift
//  VIPWallet
//
//  Created by Ryan on 2018/4/8.
//  Copyright © 2018年 Qingkong. All rights reserved.
//

import Foundation

enum ImportResult<T> {
    case succeed(result: T)
    case failed(error: Error, errorMessage: String)
}
