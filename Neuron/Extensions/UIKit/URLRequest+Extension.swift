//
//  URLRequest+Extension.swift
//  Neuron
//
//  Created by James Chen on 2018/12/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func setAcceptLanguage() {
        let acceptLanguage = Locale.preferredLanguages.joined(separator: ",")
        setValue(acceptLanguage, forHTTPHeaderField: "Accept-Language")
    }
}
