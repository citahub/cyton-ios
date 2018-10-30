//
//  NotificationName.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/19.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let createWalletSuccess = Notification.Name("createWalletSuccess")
    static let firstWalletCreated = Notification.Name("firstWalletCreated")
    static let allWalletsDeleted = Notification.Name("allWalletsDeleted")
    static let changeLocalCurrency = Notification.Name("changeLocalCurrency")
    static let switchEthNetwork = Notification.Name("switchEthNetwork")
    static let switchWallet = Notification.Name("switchWallet")
    static let beginRefresh = Notification.Name("beginRefresh")
    static let endRefresh = Notification.Name("endRefresh")
}
