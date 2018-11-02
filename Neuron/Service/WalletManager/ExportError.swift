//
//  ExportError.swift
//  Neuron
//
//  Created by James Chen on 2018/10/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

enum ExportError: Error {
    case accountNotFound
    case invalidPassword
    case unknownError
}
