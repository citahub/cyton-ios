//
//  SensorsAnalyticsService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import SensorsAnalyticsSDK

class SensorsAnalyticsService {
    static func configureSensors() {
        let sensors: SensorsAnalyticsSDK
        #if DEBUG
        sensors = SensorsAnalyticsSDK.sharedInstance(withServerURL: "https://banana.cryptape.com:8106/sa?project=default", andDebugMode: .andTrack)
        #else
        sensors = SensorsAnalyticsSDK.sharedInstance(withServerURL: "https://banana.cryptape.com:8106/sa?project=production", andDebugMode: .off)
        #endif
        sensors.trackAppCrash() // 自动收集 App Crash 日志
        sensors.registerSuperProperties(["platformType": "iOS"])
        let eventType: SensorsAnalyticsAutoTrackEventType = [
            .eventTypeAppStart,
            .eventTypeAppEnd,
            .eventTypeAppViewScreen,
            .eventTypeAppClick
        ]
        sensors.enableAutoTrack(eventType)
    }
}
