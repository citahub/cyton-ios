//
//  NervosNetWork.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import NervosSwift

class NervosNetWork {
    static public func getNervos() -> nervos{
        return Nervos.InfuraMainnetNervos()//in NervosSwift v0.173,no matter select witch network,it is always is test network
    }
}

