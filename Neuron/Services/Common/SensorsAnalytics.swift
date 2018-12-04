//
//  SensorsAnalyticsService.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import SensorsAnalyticsSDK

class SensorsAnalytics {
    enum UserDefaultsKey: String {
        case userId = "SensorsAnalyticsUserIdUserDefaultsKey"
        case ipId = "SensorsAnalyticsIpIdUserDefaultsKey"
    }
    fileprivate let sensors: SensorsAnalyticsSDK
    static let service = SensorsAnalytics()

    private init() {
        #if DEBUG
        sensors = SensorsAnalyticsSDK.sharedInstance(withServerURL: "https://banana.cryptape.com:8106/sa?project=default", andDebugMode: .andTrack)
        #else
        sensors = SensorsAnalyticsSDK.sharedInstance(withServerURL: "https://banana.cryptape.com:8106/sa?project=production", andDebugMode: .off)
        #endif
        sensors.enableLog(false)
        sensors.registerSuperProperties(["platformType": "iOS", "ip_id": getIpId(), "$ip": ""])
        let eventType: SensorsAnalyticsAutoTrackEventType = [
            .eventTypeAppStart,
            .eventTypeAppEnd,
            .eventTypeAppViewScreen,
            .eventTypeAppClick
        ]
        sensors.enableAutoTrack(eventType)
        sensors.enableTrackGPSLocation(false)
        sensors.enableTrackScreenOrientation(false)
        sensors.login(getUserId())
        sensors.trackAppCrash()

        if var automaticProperties = sensors.value(forKey: "automaticProperties") as? [String: Any] {
            automaticProperties["$device_id"] = ""
            sensors.setValue(automaticProperties, forKey: "automaticProperties")
        }
    }

    static func configureSensors() {
        _ = SensorsAnalytics.service
    }

    func track(event: String, with properties: [String: Any]) {
        sensors.track(event, withProperties: properties)
    }

    private func getUserId() -> String {
        if let userId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.rawValue) {
            return userId
        }
        var userId = ""
        for _ in 0...50 {
            userId += "\(arc4random_uniform(10))"
        }
        userId += "\(Int(Date().timeIntervalSince1970 * 1000))"
        UserDefaults.standard.set(userId, forKey: UserDefaultsKey.userId.rawValue)
        return userId
    }

    private func getIpId() -> String {
        if let ipId = UserDefaults.standard.string(forKey: UserDefaultsKey.ipId.rawValue) {
            return ipId
        }
        var ipId = ""
        for _ in 0..<64 {
            ipId += "\(arc4random_uniform(10))"
        }
        UserDefaults.standard.set(ipId, forKey: UserDefaultsKey.ipId.rawValue)
        return ipId
    }
}

extension SensorsAnalytics {
    enum ImportType: String {
        case keystore = "1"
        case mnemonic = "2"
        case privateKey = "3"
    }

    enum TransactionType: String {
        case normal = "2"
        case dApp = "1"
    }

    enum ScanQRCodeType: String {
        case none = "0"
        case walletAddress = "1"
        case privateKey = "2"
        case keystore = "3"
        case mnemonic = "4"
    }

    class Track {
        private init() { }

        fileprivate static func track(event: String, with properties: [String: Any]) {
            SensorsAnalytics.service.track(event: event, with: properties)
        }

        static func createWallet(address: String) {
            track(event: "createWallet", with: ["create_address": address])
        }

        static func importWallet(type: ImportType, address: String?) {
            track(event: "inputWallet", with: [
                "input_type": type.rawValue,
                "input_result": address != nil,
                "input_address": address ?? ""
                ])
        }

        static func transaction(chainType: String, currencyType: String, currencyNumber: Double, receiveAddress: String, outcomeAddress: String, transactionType: TransactionType) {
            track(event: "transfer_accounts", with: [
                "target_chain": chainType,
                "target_currency": currencyType,
                "target_currency_number": currencyNumber,
                "receive_address": receiveAddress,
                "outcome_address": outcomeAddress,
                "transfer_type": transactionType.rawValue
                ])
        }

        static func possessMoney(chainType: String, currencyType: String, currencyNumber: Double) {
            track(event: "possess_money", with: [
                "currency_chain": chainType,
                "currency_type": currencyType,
                "currency_number": currencyNumber
                ])
        }

        static func scanQRCode(scanType: ScanQRCodeType, scanResult: Bool) {
            track(event: "scanQRcode", with: ["scan_type": scanType.rawValue, "scan_result": scanResult])
        }

        static func error(pageTitle: String, errorName: String, errorType: String, errorContent: String) {
            track(event: "error", with: [
                "error_title": pageTitle,
                "error_name": errorName,
                "error_type": errorType,
                "error_content": errorContent
                ])
        }
    }
}

extension SensorsAnalytics.Track {
    class DApp {
        private init() { }
        private static var startUseDates = [String: TimeInterval]()

        static func clickBanner(index: Int, name: String, chain: String, category: String) {
            SensorsAnalytics.Track.track(event: "DApp_banner", with: [
                "banner_list": "\(index)",
                "DApp_name": name,
                "DApp_chain": chain,
                "DApp_category": category
                ])
        }

        static func clickButton(name: String, chain: String, category: String) {
            SensorsAnalytics.Track.track(event: "DApp_button", with: [
                "DApp_name": name,
                "DApp_chain": chain,
                "DApp_category": category
                ])
        }

        static func clickList(name: String, chain: String, category: String) {
            SensorsAnalytics.Track.track(event: "DApp_list", with: [
                "DApp_name": name,
                "DApp_chain": chain,
                "DApp_category": category
                ])
        }

        static func enterDetails(chain: String, category: String) {
            SensorsAnalytics.Track.track(event: "DApp_Details", with: ["DApp_chain": chain, "DApp_category": category])
        }

        static func startUsing(name: String, chain: String, category: String) {
            startUseDates["\(name)_\(chain)_\(category)"] = CACurrentMediaTime()
        }

        static func stopUsing(name: String, chain: String, category: String) {
            let useTimeKey = "\(name)_\(chain)_\(category)"
            guard let startDate = startUseDates[useTimeKey] else { return }
            startUseDates.removeValue(forKey: useTimeKey)
            SensorsAnalytics.Track.track(event: "DApp_usetime", with: [
                "DApp_time": CACurrentMediaTime() - startDate,
                "DApp_name": name,
                "DApp_chain": chain,
                "DApp_category": category
                ])
        }
    }
}
