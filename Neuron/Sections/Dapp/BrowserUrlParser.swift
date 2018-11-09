//
//  BrowserUrlParser.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/13.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import PlainPing

struct BrowserUrlParser {
    static func isUrlvalid( urlString: String, comletion:@escaping (Double?, Error?) -> Void ) {
        PlainPing.ping(urlString, withTimeout: 4.0, completionBlock: { ( timeElapsed: Double?, error: Error?) in
            if let error = error {
                comletion(0, error)
            } else {
                if let latency = timeElapsed {
                    comletion(latency, nil)
                }
            }
        })
    }
}
