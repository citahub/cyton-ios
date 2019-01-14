//
//  URLRequest+Extension.swift
//  Cyton
//
//  Created by James Chen on 2018/12/06.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension URLRequest {
    static var acceptLanguage: String {
        return Locale.preferredLanguages.joined(separator: ",")
    }

    mutating func setAcceptLanguage() {
        setValue(URLRequest.acceptLanguage, forHTTPHeaderField: "Accept-Language")
    }

    var acceptLanguage: String {
        return value(forHTTPHeaderField: "Accept-Language") ?? ""
    }
}
