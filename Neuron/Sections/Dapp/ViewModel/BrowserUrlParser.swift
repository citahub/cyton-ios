//
//  BrowserUrlParser.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/13.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import PlainPing

class BrowserUrlParser {

    func isUrlvalid( urlStr: String, comletion:@escaping (Double?, Error?) -> Void ) {
        PlainPing.ping(urlStr, withTimeout: 4.0, completionBlock: { ( timeElapsed: Double?, error: Error?) in
            if let error = error {
                comletion(0, error)
                print("error: \(error.localizedDescription)")
            } else {
                if let latency = timeElapsed {
                    comletion(latency, nil)
                }
            }
        })
    }

}
