//
//  RPCClient.swift
//  Neuron
//
//  Created by James Chen on 2018/12/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import Alamofire

// swiftlint:disable nesting
struct CKB {
    class RPCClient {
        private var url: URL

        init(url: URL) {
            self.url = url
        }

        typealias CompletionHandler = (_ response: Alamofire.DataResponse<Any>) -> Void

        func post(method: String, params: [Any] = [], id: Int = 1, background: Bool = false, completionHandler: CompletionHandler?) {
            request(.post, method: method, params: params, id: id, completionHandler: completionHandler)
        }
    }
}

extension CKB.RPCClient {
    private var headers: Alamofire.HTTPHeaders {
        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        return headers
    }

    private func request(_ httpMethod: Alamofire.HTTPMethod, method: String, params: [Any], id: Int, background: Bool = false, completionHandler: CompletionHandler?) {
        let parameters: Alamofire.Parameters = [
            "jsonrpc": "2.0",
            "id": id,
            "method": method,
            "params": params
        ]

        let queue = background ? DispatchQueue.global(qos: .default) : DispatchQueue.main
        Alamofire.request(url, method: httpMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                completionHandler?(response)
            }
    }
}
