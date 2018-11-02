//
//  ImportResult.swift
//  Neuron
//
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import Foundation

enum ImportResult<T> {
    case succeed(result: T)
    case failed(error: Error, errorMessage: String)
}
